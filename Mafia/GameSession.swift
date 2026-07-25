import Foundation

struct VoteResult: Identifiable {
    let player: GamePlayer
    let count: Int

    var id: UUID { player.id }
}

@MainActor
final class GameSession: ObservableObject {
    private enum StorageKey {
        static let wallpaper = "mafia.settings.wallpaper"
        static let roleSkin = "mafia.settings.roleSkin"
        static let cardSkin = "mafia.settings.cardSkin"
    }

    @Published var phase: GamePhase = .setup
    @Published var mode: GameMode = .sport
    let theme: AppTheme = .neonNoir
    @Published var wallpaper: Wallpaper {
        didSet {
            UserDefaults.standard.set(wallpaper.rawValue, forKey: StorageKey.wallpaper)
        }
    }
    @Published var roleSkin: RoleSkin {
        didSet {
            UserDefaults.standard.set(roleSkin.rawValue, forKey: StorageKey.roleSkin)
        }
    }
    @Published var cardSkin: CardSkin {
        didSet {
            UserDefaults.standard.set(cardSkin.rawValue, forKey: StorageKey.cardSkin)
        }
    }
    @Published var playerCount = 10
    @Published var playerNames = (1...10).map { "Игрок \($0)" }
    @Published var selectedConfigurationID = GameConfiguration.sport.id
    @Published var players: [GamePlayer] = []
    @Published var round = 1
    @Published var revealIndex = 0
    @Published var revealIsOpen = false
    @Published var votes: [UUID: UUID] = [:]
    @Published var currentVoterIndex = 0
    @Published var eliminationMessage: String?
    @Published var winnerText: String?
    @Published var dayMinutes = 3
    @Published var endTone: EndTone = .bell
    @Published var warnings: [UUID: PlayerWarning] = [:]
    @Published var silencedPlayers: Set<UUID> = []

    init(defaults: UserDefaults = .standard) {
        wallpaper = defaults
            .string(forKey: StorageKey.wallpaper)
            .flatMap { Wallpaper(rawValue: $0) } ?? .neonClub
        roleSkin = defaults
            .string(forKey: StorageKey.roleSkin)
            .flatMap { RoleSkin(rawValue: $0) } ?? .classic
        cardSkin = defaults
            .string(forKey: StorageKey.cardSkin)
            .flatMap { CardSkin(rawValue: $0) } ?? .obsidian
    }

    var configurations: [GameConfiguration] {
        mode == .sport ? [.sport] : GameConfiguration.classic(playerCount: playerCount)
    }

    var selectedConfiguration: GameConfiguration {
        configurations.first { $0.id == selectedConfigurationID } ?? configurations[0]
    }

    var alivePlayers: [GamePlayer] {
        players.filter(\.isAlive)
    }

    var currentVoter: GamePlayer? {
        guard currentVoterIndex < alivePlayers.count else { return nil }
        return alivePlayers[currentVoterIndex]
    }

    var votingFinished: Bool {
        currentVoterIndex >= alivePlayers.count
    }

    var voteCounts: [VoteResult] {
        alivePlayers
            .map { target in
                VoteResult(
                    player: target,
                    count: votes.values.filter { $0 == target.id }.count
                )
            }
            .sorted {
                if $0.count == $1.count { return $0.player.number < $1.player.number }
                return $0.count > $1.count
            }
    }

    func changeMode(_ newMode: GameMode) {
        mode = newMode
        setPlayerCount(newMode == .sport ? 10 : min(max(playerCount, 6), 16))
        selectedConfigurationID = configurations[0].id
    }

    func setPlayerCount(_ count: Int) {
        playerCount = count
        if playerNames.count < count {
            playerNames += ((playerNames.count + 1)...count).map { "Игрок \($0)" }
        } else if playerNames.count > count {
            playerNames = Array(playerNames.prefix(count))
        }
        if !configurations.contains(where: { $0.id == selectedConfigurationID }) {
            selectedConfigurationID = configurations[0].id
        }
    }

    func prepareGame() {
        let roles = selectedConfiguration.roles.shuffled()
        players = (0..<playerCount).map { index in
            GamePlayer(number: index + 1, name: playerNames[index], role: roles[index])
        }
        round = 1
        revealIndex = 0
        revealIsOpen = false
        votes = [:]
        winnerText = nil
        eliminationMessage = nil
        warnings = [:]
        silencedPlayers = []
        phase = .rules
    }

    func startReveal() {
        revealIndex = 0
        revealIsOpen = false
        phase = .reveal
    }

    func closeRoleAndContinue() {
        revealIsOpen = false
        if revealIndex + 1 < players.count {
            revealIndex += 1
        } else {
            phase = .hostHandoff
        }
    }

    func openHostConsole() {
        phase = .host
    }

    func beginVote() {
        votes = [:]
        currentVoterIndex = 0
        eliminationMessage = nil
        phase = .vote
    }

    func castVote(for targetID: UUID) {
        guard let voter = currentVoter else { return }
        votes[voter.id] = targetID
        currentVoterIndex += 1
    }

    func resolveVote() {
        guard let maximum = voteCounts.first?.count, maximum > 0 else {
            eliminationMessage = "Никто не исключён: голосов нет."
            return
        }
        let leaders = voteCounts.filter { $0.count == maximum }
        if leaders.count > 1 {
            eliminationMessage = "Ничья: \(leaders.map { $0.player.displayName }.joined(separator: ", ")). Никто не исключён."
        } else if let eliminated = leaders.first?.player,
                  let index = players.firstIndex(where: { $0.id == eliminated.id }) {
            players[index].isAlive = false
            eliminationMessage = "\(eliminated.displayName) исключён из игры."
        }
    }

    func continueToNight() {
        if evaluateWinner() {
            phase = .summary
        } else {
            phase = .night
        }
    }

    func finishNight(eliminatedIDs: Set<UUID>) {
        for id in eliminatedIDs {
            if let index = players.firstIndex(where: { $0.id == id }) {
                players[index].isAlive = false
            }
        }
        round += 1
        phase = evaluateWinner() ? .summary : .host
    }

    func finishNight(eliminatedIDs: Set<UUID>, silencedIDs: Set<UUID>) {
        silencedPlayers = silencedIDs.intersection(Set(alivePlayers.map(\.id)))
        finishNight(eliminatedIDs: eliminatedIDs)
    }

    func beginNight() {
        silencedPlayers.removeAll()
        phase = .host
    }

    func eliminate(_ id: UUID) {
        guard let index = players.firstIndex(where: { $0.id == id }) else { return }
        players[index].isAlive = false
        if evaluateWinner() {
            phase = .summary
        }
    }

    func toggleAlive(_ id: UUID) {
        guard let index = players.firstIndex(where: { $0.id == id }) else { return }
        players[index].isAlive.toggle()
        if !players[index].isAlive {
            silencedPlayers.remove(id)
        }
    }

    func setWarning(_ warning: PlayerWarning, for id: UUID) {
        if warning == .none {
            warnings.removeValue(forKey: id)
        } else {
            warnings[id] = warning
        }
    }

    func cycleWarning(for id: UUID) {
        switch warning(for: id) {
        case .none:
            warnings[id] = .yellow
        case .yellow:
            warnings[id] = .red
        case .red:
            warnings.removeValue(forKey: id)
        }
    }

    func warning(for id: UUID) -> PlayerWarning {
        warnings[id] ?? .none
    }

    func toggleSilenced(_ id: UUID) {
        if silencedPlayers.contains(id) {
            silencedPlayers.remove(id)
        } else {
            silencedPlayers.insert(id)
        }
    }

    func canSpeak(_ player: GamePlayer) -> Bool {
        player.isAlive
            && warning(for: player.id) != .red
            && !silencedPlayers.contains(player.id)
    }

    func canVote(_ player: GamePlayer) -> Bool {
        player.isAlive && warning(for: player.id) != .red
    }

    func resetGame() {
        phase = .setup
        players = []
        votes = [:]
        winnerText = nil
        eliminationMessage = nil
        warnings = [:]
        silencedPlayers = []
    }

    @discardableResult
    private func evaluateWinner() -> Bool {
        let alive = alivePlayers
        let mafia = alive.filter { $0.role.team == .mafia }.count
        let city = alive.filter { $0.role.team == .city }.count
        let neutral = alive.filter { $0.role.team == .neutral }.count

        if mafia == 0 && neutral == 0 {
            winnerText = "Город победил"
            return true
        }
        if mafia > 0 && mafia >= city + neutral {
            winnerText = "Мафия победила"
            return true
        }
        if neutral == 1 && alive.count == 1 {
            winnerText = "Маньяк победил"
            return true
        }
        return false
    }
}
