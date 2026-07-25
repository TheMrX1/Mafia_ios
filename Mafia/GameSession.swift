import Foundation

struct VoteResult: Identifiable {
    let player: GamePlayer
    let count: Int

    var id: UUID { player.id }
}

@MainActor
final class GameSession: ObservableObject {
    @Published var phase: GamePhase = .setup
    @Published var mode: GameMode = .sport
    @Published var theme: AppTheme = .neonNoir
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
            phase = .day
        }
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
        phase = evaluateWinner() ? .summary : .day
    }

    func resetGame() {
        phase = .setup
        players = []
        votes = [:]
        winnerText = nil
        eliminationMessage = nil
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
