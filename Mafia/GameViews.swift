import Foundation
import SwiftUI

struct RoleRevealView: View {
    @EnvironmentObject private var game: GameSession
    @State private var dossierExpanded = false
    @State private var dealCardVisible = false
    @State private var sheenMoved = false
    @State private var roleContentVisible = false
    @State private var transitionLocked = false

    var body: some View {
        let player = game.players[game.revealIndex]

        VStack(spacing: 0) {
            revealHeader(player)
                .padding(.horizontal, 22)
                .padding(.top, 10)
                .padding(.bottom, 8)

            Group {
                if game.revealIsOpen {
                    revealedRole(player)
                        .opacity(roleContentVisible ? 1 : 0)
                        .scaleEffect(roleContentVisible ? 1 : 0.965)
                        .offset(y: roleContentVisible ? 0 : 10)
                } else {
                    privacyScreen(player)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(nil, value: game.revealIsOpen)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                if game.revealIsOpen {
                    closeRole()
                } else {
                    revealRole()
                }
            } label: {
                Label(
                    game.revealIsOpen ? "Скрыть и передать дальше" : "Показать мою роль",
                    systemImage: game.revealIsOpen ? "eye.slash.fill" : "eye.fill"
                )
            }
            .buttonStyle(LuxuryButtonStyle(theme: game.theme))
            .disabled(transitionLocked)
            .opacity(transitionLocked ? 0.72 : 1)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 6)
            .background {
                LinearGradient(
                    colors: [.clear, game.theme.palette.background.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: game.revealIsOpen)
        .onAppear {
            prepareClosedCard()
        }
        .onChange(of: game.revealIndex) {
            dossierExpanded = false
            prepareClosedCard()
        }
    }

    private func revealHeader(_ player: GamePlayer) -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 7) {
                ForEach(0..<game.players.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index <= game.revealIndex
                                ? game.theme.palette.accent
                                : game.theme.palette.border
                        )
                        .frame(width: index == game.revealIndex ? 22 : 7, height: 4)
                }
            }
            .animation(.spring(response: 0.44, dampingFraction: 0.78), value: game.revealIndex)

            Spacer()

            Text("\(game.revealIndex + 1)/\(game.players.count)")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(game.theme.palette.secondaryText)

            Text(String(format: "%02d", player.number))
                .font(.caption.monospacedDigit().bold())
                .foregroundStyle(game.theme.palette.accent)
        }
    }

    private func privacyScreen(_ player: GamePlayer) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 10) {
                Text("ПЕРЕДАЙТЕ ТЕЛЕФОН")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(2.8)
                    .foregroundStyle(game.theme.palette.secondaryText)

                Text(player.displayName)
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)

                Text("Карту должен видеть только этот игрок")
                    .font(.callout)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 18)

            secretCard

            Spacer(minLength: 18)

            Label("КОСНИТЕСЬ КНОПКИ, ЧТОБЫ ОТКРЫТЬ", systemImage: "lock.fill")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .tracking(1.25)
                .foregroundStyle(game.theme.palette.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
    }

    private var secretCard: some View {
        CardBackView(skin: game.cardSkin, theme: game.theme, cornerRadius: 28)
            .frame(width: 218, height: 292)
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.34),
                            Color.white.opacity(0.05),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 74)
                    .rotationEffect(.degrees(18))
                    .offset(x: sheenMoved ? proxy.size.width + 40 : -114)
                }
                .mask {
                    CardBackShape(maximumCornerRadius: 28)
                }
                .allowsHitTesting(false)
            }
            .rotation3DEffect(
                .degrees(dealCardVisible ? 0 : -18),
                axis: (x: 0.10, y: 1, z: 0),
                perspective: 0.72
            )
            .rotationEffect(.degrees(dealCardVisible ? 0 : -5))
            .scaleEffect(dealCardVisible ? 1 : 0.78)
            .offset(y: dealCardVisible ? 0 : 28)
            .opacity(dealCardVisible ? 1 : 0)
            .shadow(
                color: game.theme.palette.accent.opacity(dealCardVisible ? 0.22 : 0.06),
                radius: dealCardVisible ? 26 : 8,
                y: dealCardVisible ? 18 : 4
            )
            .accessibilityHidden(true)
    }

    private func prepareClosedCard() {
        guard !game.revealIsOpen else {
            roleContentVisible = true
            return
        }

        dealCardVisible = false
        sheenMoved = false
        roleContentVisible = false

        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.58, dampingFraction: 0.76)) {
                dealCardVisible = true
            }
            withAnimation(.easeInOut(duration: 0.68).delay(0.16)) {
                sheenMoved = true
            }
        }
    }

    private func revealRole() {
        guard !transitionLocked else { return }
        transitionLocked = true

        withAnimation(.easeIn(duration: 0.18)) {
            dealCardVisible = false
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 180_000_000)
            game.revealIsOpen = true
            roleContentVisible = false
            await Task.yield()
            withAnimation(.spring(response: 0.50, dampingFraction: 0.84)) {
                roleContentVisible = true
            }
            transitionLocked = false
        }
    }

    private func closeRole() {
        guard !transitionLocked else { return }
        transitionLocked = true

        withAnimation(.easeIn(duration: 0.14)) {
            roleContentVisible = false
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 140_000_000)
            game.closeRoleAndContinue()
            transitionLocked = false
        }
    }

    private func revealedRole(_ player: GamePlayer) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                RoleArtwork(role: player.role, height: 286)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(player.role.team.title)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(game.theme.palette.accent)
                        Text(player.role.name)
                            .font(.system(size: 34, weight: .bold, design: .serif))
                    }
                    .padding(18)
                }
                .shadow(color: .black.opacity(0.26), radius: 24, y: 12)

                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ВАША ЦЕЛЬ")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(game.theme.palette.accent)
                        Text(player.role.objective)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let action = player.role.nightAction {
                        HStack(spacing: 10) {
                            Image(systemName: "moon.stars.fill")
                                .foregroundStyle(game.theme.palette.accent)
                            Text(action)
                                .font(.subheadline.weight(.semibold))
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(game.theme.palette.accent.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }

                    Button {
                        dossierExpanded.toggle()
                    } label: {
                        HStack {
                            Text(dossierExpanded ? "Скрыть досье" : "Полное досье")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption.bold())
                                .rotationEffect(.degrees(dossierExpanded ? 180 : 0))
                                .animation(.easeOut(duration: 0.16), value: dossierExpanded)
                        }
                        .foregroundStyle(game.theme.palette.secondaryText)
                    }
                    .buttonStyle(.plain)

                    if dossierExpanded {
                        VStack(alignment: .leading, spacing: 14) {
                            Divider().overlay(game.theme.palette.border)
                            dossierSection("О РОЛИ", text: player.role.summary)
                            dossierSection("ПРАВИЛА", text: player.role.details)
                            dossierSection("ТАКТИКА", text: player.role.strategy)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .mafiaCard(game.theme, padding: 15)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        .scrollIndicators(.hidden)
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

struct HostHandoffView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(game.theme.palette.accent.opacity(0.14))
                    .frame(width: 132, height: 132)
                Circle()
                    .stroke(game.theme.palette.accent.opacity(0.42), lineWidth: 1)
                    .frame(width: 106, height: 106)
                Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                    .font(.system(size: 46, weight: .light))
                    .foregroundStyle(game.theme.palette.accent)
            }

            VStack(spacing: 12) {
                Text("РОЛИ РАСПРЕДЕЛЕНЫ")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(2.8)
                    .foregroundStyle(game.theme.palette.accent)

                Text("Передайте устройство\nведущему")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)

                Text("Следующий экран покажет роли и состояние всего стола.")
                    .font(.callout)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }

            Spacer()

            Button {
                game.openHostConsole()
            } label: {
                Label("Открыть пульт ведущего", systemImage: "lock.open.fill")
            }
            .buttonStyle(LuxuryButtonStyle(theme: game.theme))
        }
        .contentColumn()
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 12)
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
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 8
                    ) {
                        ForEach(game.players) { player in
                            PlayerStatusRow(player: player)
                        }
                    }
                }
                .mafiaCard(game.theme, padding: 14)

                Button {
                    dayTimer.stop()
                    game.beginVote()
                } label: {
                    Label("Начать голосование", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
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
        HStack(spacing: 8) {
            Text(String(format: "%02d", player.number))
                .font(.caption2.monospacedDigit().bold())
                .foregroundStyle(player.isAlive ? game.theme.palette.accent : game.theme.palette.secondaryText)
                .frame(width: 22)
            Text(player.displayName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .strikethrough(!player.isAlive)
            Spacer()
            Circle()
                .fill(player.isAlive ? game.theme.palette.secondaryAccent : game.theme.palette.secondaryText)
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 9)
        .frame(minHeight: 38)
        .background(game.theme.palette.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
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
                    .buttonStyle(LuxuryButtonStyle(theme: game.theme))
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
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
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
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
            }
        }
    }
}

struct NightView: View {
    @EnvironmentObject private var game: GameSession
    @State private var eliminated: Set<UUID> = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                ScreenHeader(
                    "Ночь \(game.round)",
                    title: "Город засыпает",
                    subtitle: "Проведите ночные действия и отметьте выбывших."
                )

                eliminationCard

                Button {
                    game.finishNight(eliminatedIDs: eliminated)
                } label: {
                    Label("Начать новый день", systemImage: "sun.max.fill")
                }
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
        }
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
                            Image(player.role.artwork(for: game.roleSkin))
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
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
        }
    }
}
