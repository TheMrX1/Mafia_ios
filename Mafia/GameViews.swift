import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RoleRevealView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        let player = game.players[game.revealIndex]

        ScrollView {
            VStack(spacing: 22) {
                HStack {
                    Text("КАРТА \(game.revealIndex + 1) ИЗ \(game.players.count)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(2.2)
                        .foregroundStyle(game.theme.palette.secondaryText)
                    Spacer()
                    Text(String(format: "%02d", player.number))
                        .font(.caption.monospacedDigit().bold())
                        .foregroundStyle(game.theme.palette.accent)
                }

                if game.revealIsOpen {
                    revealedRole(player)
                        .transition(.scale(scale: 0.96).combined(with: .opacity))
                } else {
                    privacyScreen(player)
                        .transition(.opacity)
                }
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 116)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                withAnimation(.snappy) {
                    if game.revealIsOpen {
                        game.closeRoleAndContinue()
                    } else {
                        game.revealIsOpen = true
                    }
                }
            } label: {
                Label(
                    game.revealIsOpen ? "Скрыть и передать дальше" : "Показать мою роль",
                    systemImage: game.revealIsOpen ? "eye.slash.fill" : "eye.fill"
                )
            }
            .primaryButton(game.theme)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
    }

    private func privacyScreen(_ player: GamePlayer) -> some View {
        VStack(spacing: 22) {
            Spacer(minLength: 40)

            ZStack {
                Circle()
                    .fill(game.theme.palette.accent.opacity(0.12))
                    .frame(width: 150, height: 150)
                Circle()
                    .stroke(game.theme.palette.accent.opacity(0.28), lineWidth: 1)
                    .frame(width: 126, height: 126)
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(game.theme.palette.accent)
            }

            VStack(spacing: 8) {
                Text("Передайте телефон")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                Text(player.displayName)
                    .font(.title3.bold())
                    .foregroundStyle(game.theme.palette.accent)
                Text("Продолжайте, только когда никто другой не видит экран.")
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }

            HStack(spacing: 9) {
                Image(systemName: "lock.fill")
                Text("Роль скрыта")
            }
            .font(.caption.bold())
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(game.theme.palette.elevatedSurface)
            .clipShape(Capsule())

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 560)
        .mafiaCard(game.theme)
    }

    private func revealedRole(_ player: GamePlayer) -> some View {
        VStack(spacing: 18) {
            RoleArtwork(role: player.role, height: 310)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(player.role.team.title)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(game.theme.palette.accent)
                        Text(player.role.name)
                            .font(.system(size: 36, weight: .bold, design: .serif))
                    }
                    .padding(20)
                }

            VStack(alignment: .leading, spacing: 18) {
                Text(player.role.summary)
                    .font(.title3.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Divider().overlay(game.theme.palette.border)

                dossierSection("ВАША ЗАДАЧА", text: player.role.details)

                if let action = player.role.nightAction {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .foregroundStyle(game.theme.palette.accent)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ДЕЙСТВИЕ НОЧЬЮ")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .tracking(1.4)
                                .foregroundStyle(game.theme.palette.secondaryText)
                            Text(action)
                                .font(.subheadline.weight(.semibold))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(game.theme.palette.accent.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                dossierSection("ТАКТИКА", text: player.role.strategy)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .mafiaCard(game.theme)
        }
    }

    private func dossierSection(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(game.theme.palette.accent)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(game.theme.palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct DayView: View {
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var dayTimer: DayCountdown

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                ScreenHeader(
                    "День \(game.round)",
                    title: "Город просыпается",
                    subtitle: "Обсудите события ночи и решите, кому можно доверять."
                )

                VStack(spacing: 18) {
                    HStack {
                        Label(dayTimer.isRunning ? "ЭФИР ИДЁТ" : "ТАЙМЕР ГОТОВ", systemImage: dayTimer.isRunning ? "waveform" : "timer")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(game.theme.palette.accent)
                        Spacer()
                        Text("\(game.dayMinutes) МИН")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(game.theme.palette.secondaryText)
                    }

                    Text(dayTimer.formatted)
                        .font(.system(size: 68, weight: .light, design: .monospaced))
                        .minimumScaleFactor(0.72)
                        .contentTransition(.numericText())

                    HStack(spacing: 10) {
                        Button {
                            dayTimer.toggle(tone: game.endTone)
                        } label: {
                            Label(dayTimer.isRunning ? "Пауза" : "Старт", systemImage: dayTimer.isRunning ? "pause.fill" : "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(game.theme.palette.accent)

                        Button {
                            dayTimer.reset(minutes: game.dayMinutes)
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .frame(width: 42)
                        }
                        .buttonStyle(.bordered)
                        .tint(game.theme.palette.text)
                    }
                }
                .mafiaCard(game.theme)

                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel("Состав стола", detail: "\(game.alivePlayers.count) в игре")
                    ForEach(game.players) { player in
                        PlayerStatusRow(player: player)
                    }
                }
                .mafiaCard(game.theme)

                Button {
                    dayTimer.stop()
                    game.beginVote()
                } label: {
                    Label("Начать голосование", systemImage: "checkmark.seal.fill")
                }
                .primaryButton(game.theme)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
            .onAppear {
                if dayTimer.remaining == 0 || !dayTimer.isRunning {
                    dayTimer.reset(minutes: game.dayMinutes)
                }
            }
        }
    }
}

private struct PlayerStatusRow: View {
    @EnvironmentObject private var game: GameSession
    let player: GamePlayer

    var body: some View {
        HStack(spacing: 12) {
            Text(String(format: "%02d", player.number))
                .font(.caption.monospacedDigit().bold())
                .foregroundStyle(player.isAlive ? game.theme.palette.accent : game.theme.palette.secondaryText)
                .frame(width: 26)
            Text(player.displayName)
                .font(.subheadline.weight(.semibold))
                .strikethrough(!player.isAlive)
            Spacer()
            Text(player.isAlive ? "В ИГРЕ" : "ВЫБЫЛ")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .tracking(1)
                .foregroundStyle(player.isAlive ? game.theme.palette.secondaryAccent : game.theme.palette.secondaryText)
        }
        .padding(.vertical, 7)
        .opacity(player.isAlive ? 1 : 0.48)
    }
}

struct VoteView: View {
    @EnvironmentObject private var game: GameSession
    @State private var selectedTarget: UUID?
    @State private var resultResolved = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ScreenHeader(
                    "Решение города",
                    title: game.votingFinished ? "Результаты" : "Голосование",
                    subtitle: game.votingFinished ? "Все голоса приняты." : "Каждый выбор остаётся приватным."
                )

                if !game.votingFinished {
                    voterCard
                    candidateList

                    Button {
                        guard let selectedTarget else { return }
                        withAnimation(.snappy) {
                            game.castVote(for: selectedTarget)
                            self.selectedTarget = nil
                        }
                    } label: {
                        Label("Подтвердить голос", systemImage: "checkmark")
                    }
                    .primaryButton(game.theme)
                    .disabled(selectedTarget == nil)
                    .opacity(selectedTarget == nil ? 0.48 : 1)
                } else {
                    resultList
                }
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
        }
    }

    private var voterCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(game.theme.palette.accent.opacity(0.14))
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .foregroundStyle(game.theme.palette.accent)
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 3) {
                Text("СЕЙЧАС ГОЛОСУЕТ")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(game.theme.palette.secondaryText)
                Text(game.currentVoter?.displayName ?? "")
                    .font(.title3.bold())
            }
            Spacer()
            Text("\(game.currentVoterIndex + 1)/\(game.alivePlayers.count)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(game.theme.palette.accent)
        }
        .mafiaCard(game.theme)
    }

    private var candidateList: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("Выберите игрока")
            ForEach(game.alivePlayers) { candidate in
                Button {
                    withAnimation(.snappy) {
                        selectedTarget = candidate.id
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(String(format: "%02d", candidate.number))
                            .font(.caption.monospacedDigit().bold())
                            .foregroundStyle(game.theme.palette.accent)
                        Text(candidate.displayName)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: selectedTarget == candidate.id ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(selectedTarget == candidate.id ? game.theme.palette.accent : game.theme.palette.secondaryText)
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 52)
                    .background(game.theme.palette.elevatedSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(selectedTarget == candidate.id ? game.theme.palette.accent : game.theme.palette.border, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var resultList: some View {
        VStack(spacing: 14) {
            ForEach(game.voteCounts.indices, id: \.self) { index in
                let item = game.voteCounts[index]
                HStack(spacing: 14) {
                    Text("\(index + 1)")
                        .font(.caption.monospacedDigit().bold())
                        .foregroundStyle(game.theme.palette.secondaryText)
                        .frame(width: 22)
                    Text(item.player.displayName)
                        .font(.headline)
                    Spacer()
                    Text("\(item.count)")
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundStyle(game.theme.palette.accent)
                }
                .mafiaCard(game.theme, padding: 14)
            }

            if !resultResolved {
                Button("Подвести итог") {
                    withAnimation(.snappy) {
                        game.resolveVote()
                        resultResolved = true
                    }
                }
                .primaryButton(game.theme)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "gavel.fill")
                        .font(.title)
                        .foregroundStyle(game.theme.palette.accent)
                    Text(game.eliminationMessage ?? "")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .mafiaCard(game.theme)

                Button("Город засыпает") {
                    game.continueToNight()
                }
                .primaryButton(game.theme)
            }
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
            LazyVStack(spacing: 22) {
                ScreenHeader(
                    "Ночь \(game.round)",
                    title: "Город засыпает",
                    subtitle: "Скройте разговоры музыкой и проведите ночные действия."
                )

                musicCard
                eliminationCard

                Button {
                    music.stop()
                    game.finishNight(eliminatedIDs: eliminated)
                } label: {
                    Label("Начать новый день", systemImage: "sun.max.fill")
                }
                .primaryButton(game.theme)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
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

    private var musicCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel("Музыка ночи", detail: music.isPlaying ? "играет" : nil)

            if let track = music.trackName {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(game.theme.palette.accent.opacity(0.14))
                        Image(systemName: "waveform")
                            .foregroundStyle(game.theme.palette.accent)
                            .symbolEffect(.variableColor.iterative, isActive: music.isPlaying)
                    }
                    .frame(width: 52, height: 52)

                    Text(track)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Spacer()
                    Button {
                        music.toggle()
                    } label: {
                        Image(systemName: music.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(game.theme.palette.accent)
                    }
                }
            } else {
                Text("Добавьте спокойный трек — он скроет звуки ночных перемещений.")
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(music.trackName == nil ? "Выбрать из Файлов" : "Заменить трек") {
                importerPresented = true
            }
            .buttonStyle(.bordered)
            .tint(game.theme.palette.accent)

            if let error = music.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .mafiaCard(game.theme)
    }

    private var eliminationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Итог ночи", detail: eliminated.isEmpty ? "без жертв" : "\(eliminated.count) выбрано")
            Text("Отметьте выбывших. Если никто не погиб, оставьте список пустым.")
                .font(.footnote)
                .foregroundStyle(game.theme.palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(game.alivePlayers) { player in
                Button {
                    withAnimation(.snappy) {
                        if eliminated.contains(player.id) {
                            eliminated.remove(player.id)
                        } else {
                            eliminated.insert(player.id)
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(String(format: "%02d", player.number))
                            .font(.caption.monospacedDigit().bold())
                            .foregroundStyle(game.theme.palette.accent)
                        Text(player.displayName)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: eliminated.contains(player.id) ? "xmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(eliminated.contains(player.id) ? game.theme.palette.accent : game.theme.palette.secondaryText)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .mafiaCard(game.theme)
    }
}

struct SummaryView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                Spacer(minLength: 12)
                ZStack {
                    Circle()
                        .fill(game.theme.palette.accent.opacity(0.13))
                        .frame(width: 124, height: 124)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(game.theme.palette.accent)
                }

                ScreenHeader(
                    "Финал",
                    title: game.winnerText ?? "Игра окончена",
                    subtitle: "\(game.round) раундов · \(game.players.count) игроков"
                )
                .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel("Все роли раскрыты")
                    ForEach(game.players) { player in
                        HStack(spacing: 12) {
                            Image(player.role.artwork)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(player.displayName)
                                    .font(.subheadline.weight(.semibold))
                                Text(player.role.name)
                                    .font(.caption)
                                    .foregroundStyle(game.theme.palette.secondaryText)
                            }
                            Spacer()
                            Image(systemName: player.isAlive ? "heart.fill" : "xmark")
                                .foregroundStyle(player.isAlive ? game.theme.palette.secondaryAccent : game.theme.palette.secondaryText)
                        }
                    }
                }
                .mafiaCard(game.theme)

                Button("Новая игра") {
                    game.resetGame()
                }
                .primaryButton(game.theme)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
        }
    }
}