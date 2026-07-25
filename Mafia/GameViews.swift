import SwiftUI
import UniformTypeIdentifiers

struct RoleRevealView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        let player = game.players[game.revealIndex]
        VStack(spacing: 24) {
            Spacer()
            if game.revealIsOpen {
                Image(systemName: player.role.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(game.theme.palette.accent)
                Text(player.role.name)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(player.role.summary)
                    .font(.title3)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .multilineTextAlignment(.center)
                if let action = player.role.nightAction {
                    Label(action, systemImage: "moon.stars.fill")
                        .font(.subheadline)
                        .padding()
                        .mafiaCard(game.theme)
                }
            } else {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(game.theme.palette.accent)
                Text("Передайте телефон")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Text(player.displayName)
                    .font(.title2)
                Text("Убедитесь, что экран видите только вы.")
                    .foregroundStyle(game.theme.palette.secondaryText)
            }
            Spacer()
            Button(game.revealIsOpen ? "Скрыть и передать дальше" : "Показать мою роль") {
                if game.revealIsOpen {
                    game.closeRoleAndContinue()
                } else {
                    game.revealIsOpen = true
                }
            }
            .primaryButton(game.theme)
        }
        .padding(24)
    }
}

struct DayView: View {
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var dayTimer: DayCountdown

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 5) {
                    Text("ДЕНЬ \(game.round)")
                        .font(.caption.bold())
                        .tracking(4)
                        .foregroundStyle(game.theme.palette.accent)
                    Text("Город просыпается")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }

                VStack(spacing: 16) {
                    Text(dayTimer.formatted)
                        .font(.system(size: 64, weight: .light, design: .monospaced))
                        .contentTransition(.numericText())
                    HStack {
                        Button(dayTimer.isRunning ? "Пауза" : "Старт") {
                            dayTimer.toggle(tone: game.endTone)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(game.theme.palette.accent)
                        Button("Сбросить") {
                            dayTimer.reset(minutes: game.dayMinutes)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .mafiaCard(game.theme)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("В игре").font(.headline)
                        Spacer()
                        Text("\(game.alivePlayers.count)")
                            .foregroundStyle(game.theme.palette.accent)
                    }
                    ForEach(game.players) { player in
                        HStack {
                            Circle()
                                .fill(player.isAlive ? game.theme.palette.secondaryAccent : game.theme.palette.secondaryText)
                                .frame(width: 8, height: 8)
                            Text(player.displayName)
                            Spacer()
                            if !player.isAlive {
                                Text("выбыл")
                                    .font(.caption)
                                    .foregroundStyle(game.theme.palette.secondaryText)
                            }
                        }
                        .opacity(player.isAlive ? 1 : 0.45)
                    }
                }
                .mafiaCard(game.theme)

                Button("Начать голосование") {
                    dayTimer.stop()
                    game.beginVote()
                }
                .primaryButton(game.theme)
            }
            .padding(20)
            .onAppear {
                if dayTimer.remaining == 0 || !dayTimer.isRunning {
                    dayTimer.reset(minutes: game.dayMinutes)
                }
            }
        }
    }
}

struct VoteView: View {
    @EnvironmentObject private var game: GameSession
    @State private var selectedTarget: UUID?
    @State private var resultResolved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Голосование")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                if !game.votingFinished {
                    Text("Передайте телефон игроку")
                        .foregroundStyle(game.theme.palette.secondaryText)
                    Text(game.currentVoter?.displayName ?? "")
                        .font(.title.bold())
                        .foregroundStyle(game.theme.palette.accent)

                    VStack(spacing: 10) {
                        ForEach(game.alivePlayers) { candidate in
                            Button {
                                selectedTarget = candidate.id
                            } label: {
                                HStack {
                                    Text(candidate.displayName)
                                    Spacer()
                                    Image(systemName: selectedTarget == candidate.id ? "checkmark.circle.fill" : "circle")
                                }
                                .padding()
                                .background(game.theme.palette.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button("Подтвердить голос") {
                        guard let selectedTarget else { return }
                        game.castVote(for: selectedTarget)
                        self.selectedTarget = nil
                    }
                    .primaryButton(game.theme)
                    .disabled(selectedTarget == nil)
                    .opacity(selectedTarget == nil ? 0.5 : 1)
                } else {
                    Text("Результаты")
                        .font(.title2.bold())
                    ForEach(game.voteCounts) { item in
                        HStack {
                            Text(item.player.displayName)
                            Spacer()
                            Text("\(item.count)")
                                .font(.title3.monospacedDigit().bold())
                                .foregroundStyle(game.theme.palette.accent)
                        }
                        .mafiaCard(game.theme)
                    }

                    if !resultResolved {
                        Button("Подвести итог") {
                            game.resolveVote()
                            resultResolved = true
                        }
                        .primaryButton(game.theme)
                    } else {
                        Text(game.eliminationMessage ?? "")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .mafiaCard(game.theme)
                        Button("Город засыпает") {
                            game.continueToNight()
                        }
                        .primaryButton(game.theme)
                    }
                }
            }
            .padding(20)
        }
    }
}

struct NightView: View {
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var music: NightMusic
    @State private var eliminated: Set<UUID> = []
    @State private var importerPresented = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(game.theme.palette.accent)
                Text("Город засыпает")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("Раунд \(game.round)")
                    .foregroundStyle(game.theme.palette.secondaryText)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Музыка ночи").font(.headline)
                    if let track = music.trackName {
                        HStack {
                            Image(systemName: "waveform")
                            Text(track).lineLimit(1)
                            Spacer()
                            Button {
                                music.toggle()
                            } label: {
                                Image(systemName: music.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title)
                            }
                        }
                    }
                    Button(music.trackName == nil ? "Выбрать из Файлов" : "Заменить трек") {
                        importerPresented = true
                    }
                    .buttonStyle(.bordered)
                    .tint(game.theme.palette.accent)
                    if let error = music.errorMessage {
                        Text(error).font(.caption).foregroundStyle(.red)
                    }
                }
                .mafiaCard(game.theme)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Кто выбыл этой ночью?").font(.headline)
                    Text("Если никто — оставьте список пустым.")
                        .font(.caption)
                        .foregroundStyle(game.theme.palette.secondaryText)
                    ForEach(game.alivePlayers) { player in
                        Button {
                            if eliminated.contains(player.id) {
                                eliminated.remove(player.id)
                            } else {
                                eliminated.insert(player.id)
                            }
                        } label: {
                            HStack {
                                Text(player.displayName)
                                Spacer()
                                Image(systemName: eliminated.contains(player.id) ? "xmark.circle.fill" : "circle")
                                    .foregroundStyle(eliminated.contains(player.id) ? game.theme.palette.accent : game.theme.palette.secondaryText)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .mafiaCard(game.theme)

                Button("Начать новый день") {
                    music.stop()
                    game.finishNight(eliminatedIDs: eliminated)
                }
                .primaryButton(game.theme)
            }
            .padding(20)
        }
        .fileImporter(
            isPresented: $importerPresented,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                music.importTrack(from: url)
            }
        }
    }
}

struct SummaryView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                Image(systemName: "crown.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(game.theme.palette.accent)
                Text(game.winnerText ?? "Игра окончена")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                VStack(spacing: 10) {
                    ForEach(game.players) { player in
                        HStack {
                            Text(player.displayName)
                            Spacer()
                            Label(player.role.name, systemImage: player.role.icon)
                                .font(.subheadline)
                                .foregroundStyle(game.theme.palette.secondaryText)
                        }
                    }
                }
                .mafiaCard(game.theme)
                Button("Новая игра") {
                    game.resetGame()
                }
                .primaryButton(game.theme)
            }
            .padding(20)
        }
    }
}
