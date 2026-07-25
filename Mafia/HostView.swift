import SwiftUI

private enum HostSection: String, CaseIterable, Identifiable {
    case overview
    case timer
    case vote

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "Стол"
        case .timer: "Таймер"
        case .vote: "Голосование"
        }
    }

    var icon: String {
        switch self {
        case .overview: "person.3.fill"
        case .timer: "timer"
        case .vote: "hand.raised.fill"
        }
    }
}

private enum NightStage {
    case neutral
    case active
    case report
}

private struct NightReport {
    let eliminated: [GamePlayer]
    let saved: [GamePlayer]
    let silenced: [GamePlayer]
}

struct HostView: View {
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var timer: DayCountdown
    @State private var section: HostSection = .overview
    @State private var nightStage: NightStage = .neutral
    @State private var killed: Set<UUID> = []
    @State private var protected: Set<UUID> = []
    @State private var blocked: Set<UUID> = []
    @State private var report: NightReport?
    @State private var nominees: [UUID] = []
    @State private var voteCounts: [UUID: Int] = [:]
    @State private var manualMinutes = 1
    @State private var manualSeconds = 0

    var body: some View {
        VStack(spacing: 0) {
            hostHeader

            Group {
                if nightStage == .active {
                    nightPanel
                } else if nightStage == .report {
                    nightReportPanel
                } else {
                    switch section {
                    case .overview:
                        overviewPanel
                    case .timer:
                        timerPanel
                    case .vote:
                        votePanel
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transaction { transaction in
                transaction.animation = nil
            }

            if nightStage == .neutral {
                sectionBar
            }
        }
        .sensoryFeedback(.selection, trigger: section)
    }

    private var hostHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("ПУЛЬТ ВЕДУЩЕГО")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(2.5)
                    .foregroundStyle(game.theme.palette.accent)
                Text(headerTitle)
                    .font(.system(size: 28, weight: .bold, design: .serif))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("РАУНД \(game.round)")
                    .font(.caption2.bold())
                    .foregroundStyle(game.theme.palette.secondaryText)
                Text("\(game.alivePlayers.count) в игре")
                    .font(.caption.monospacedDigit().weight(.semibold))
            }
            .padding(.trailing, 48)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var headerTitle: String {
        switch nightStage {
        case .active: "Город спит"
        case .report: "Итог ночи"
        case .neutral: section.title
        }
    }

    private var sectionBar: some View {
        HStack(spacing: 6) {
            ForEach(HostSection.allCases) { item in
                Button {
                    section = item
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.icon)
                            .font(.system(size: 16, weight: .semibold))
                        Text(item.title)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(
                        section == item
                            ? game.theme.palette.buttonText
                            : game.theme.palette.secondaryText
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        section == item
                            ? game.theme.palette.accent
                            : game.theme.palette.elevatedSurface
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(game.theme.palette.background.opacity(0.96))
    }

    private var overviewPanel: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                Button {
                    game.beginNight()
                    killed.removeAll()
                    protected.removeAll()
                    blocked.removeAll()
                    report = nil
                    nightStage = .active
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(game.theme.palette.buttonText.opacity(0.12))
                            Image(systemName: "moon.stars.fill")
                                .font(.title3)
                        }
                        .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Начать ночь")
                                .font(.headline)
                            Text("Открыть роли и ночные действия")
                                .font(.caption)
                                .opacity(0.72)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))

                HStack {
                    SectionLabel("Состояние игроков", detail: "\(game.players.count)")
                    Spacer()
                }
                .padding(.top, 4)

                ForEach(game.players) { player in
                    overviewPlayerCard(player)
                }
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func overviewPlayerCard(_ player: GamePlayer) -> some View {
        VStack(spacing: 11) {
            HStack(spacing: 11) {
                Image(player.role.artwork(for: game.roleSkin))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .grayscale(player.isAlive ? 0 : 1)

                Text(String(format: "%02d", player.number))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(game.theme.palette.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.displayName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(player.role.name)
                        .font(.caption)
                        .foregroundStyle(game.theme.palette.secondaryText)
                }

                Spacer(minLength: 4)

                Text(player.isAlive ? "ЖИВ" : "ВЫБЫЛ")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(
                        player.isAlive
                            ? game.theme.palette.secondaryAccent
                            : game.theme.palette.secondaryText
                    )
            }

            HStack(spacing: 7) {
                warningBadge(player)
                capabilityBadge(
                    title: "Речь",
                    icon: game.canSpeak(player) ? "mic.fill" : "mic.slash.fill",
                    enabled: game.canSpeak(player)
                )
                capabilityBadge(
                    title: "Голос",
                    icon: game.canVote(player) ? "hand.thumbsup.fill" : "hand.raised.slash.fill",
                    enabled: game.canVote(player)
                )
            }

            HStack(spacing: 8) {
                Menu {
                    Button("Без предупреждений") {
                        game.setWarning(.none, for: player.id)
                    }
                    Button("Жёлтая карточка") {
                        game.setWarning(.yellow, for: player.id)
                    }
                    Button("Красная карточка") {
                        game.setWarning(.red, for: player.id)
                    }
                } label: {
                    Label("Карточка", systemImage: "rectangle.portrait.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(game.theme.palette.text)

                Button {
                    game.toggleSilenced(player.id)
                } label: {
                    Label(
                        game.silencedPlayers.contains(player.id) ? "Разрешить речь" : "Заглушить",
                        systemImage: game.silencedPlayers.contains(player.id) ? "mic.fill" : "mic.slash.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(game.theme.palette.accent)
                .disabled(!player.isAlive)

                Button {
                    game.toggleAlive(player.id)
                } label: {
                    Image(systemName: player.isAlive ? "person.fill.xmark" : "arrow.uturn.backward")
                        .frame(width: 32)
                }
                .buttonStyle(.bordered)
                .tint(player.isAlive ? .red : game.theme.palette.secondaryAccent)
            }
            .font(.caption2.weight(.bold))
        }
        .mafiaCard(game.theme, padding: 11)
        .opacity(player.isAlive ? 1 : 0.58)
    }

    private func warningBadge(_ player: GamePlayer) -> some View {
        let warning = game.warning(for: player.id)

        return HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(warningColor(warning))
                .frame(width: 10, height: 14)
            Text(warning == .none ? "Чисто" : warning == .yellow ? "Жёлтая" : "Красная")
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(game.theme.palette.secondaryText)
        .frame(maxWidth: .infinity)
        .frame(height: 28)
        .background(game.theme.palette.elevatedSurface)
        .clipShape(Capsule())
    }

    private func warningColor(_ warning: PlayerWarning) -> Color {
        switch warning {
        case .none: game.theme.palette.secondaryText.opacity(0.38)
        case .yellow: Color.yellow
        case .red: Color.red
        }
    }

    private func capabilityBadge(
        title: String,
        icon: String,
        enabled: Bool
    ) -> some View {
        Label(title, systemImage: icon)
            .font(.caption2.weight(.bold))
            .foregroundStyle(
                enabled
                    ? game.theme.palette.secondaryAccent
                    : game.theme.palette.secondaryText
            )
            .frame(maxWidth: .infinity)
            .frame(height: 28)
            .background(game.theme.palette.elevatedSurface)
            .clipShape(Capsule())
            .opacity(enabled ? 1 : 0.64)
    }

    private var nightPanel: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                Text("Отметьте покушения, защиту и блокировку. Защищённый игрок переживёт покушение.")
                    .font(.footnote)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(game.players) { player in
                        nightRoleCard(player)
                    }
                }

                Button {
                    buildNightReport()
                } label: {
                    Label("Завершить ночь", systemImage: "sunrise.fill")
                }
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
                .padding(.top, 4)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func nightRoleCard(_ player: GamePlayer) -> some View {
        VStack(spacing: 9) {
            ZStack(alignment: .bottomLeading) {
                Image(player.role.artwork(for: game.roleSkin))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 112)
                    .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.84)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "№%02d", player.number))
                        .font(.caption.monospacedDigit().bold())
                        .foregroundStyle(game.theme.palette.accent)
                    Text(player.role.name)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .padding(9)
            }
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .grayscale(player.isAlive ? 0 : 1)

            if player.isAlive {
                HStack(spacing: 5) {
                    nightAction(
                        icon: "scope",
                        active: killed.contains(player.id),
                        color: .red
                    ) {
                        toggle(player.id, in: &killed)
                    }
                    nightAction(
                        icon: "cross.case.fill",
                        active: protected.contains(player.id),
                        color: game.theme.palette.secondaryAccent
                    ) {
                        toggle(player.id, in: &protected)
                    }
                    nightAction(
                        icon: "mic.slash.fill",
                        active: blocked.contains(player.id),
                        color: game.theme.palette.accent
                    ) {
                        toggle(player.id, in: &blocked)
                    }
                }
            } else {
                Text("ВЫБЫЛ")
                    .font(.caption2.bold())
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .frame(height: 30)
            }
        }
        .mafiaCard(game.theme, padding: 8)
        .opacity(player.isAlive ? 1 : 0.52)
    }

    private func nightAction(
        icon: String,
        active: Bool,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .foregroundStyle(active ? Color.white : game.theme.palette.secondaryText)
                .background(active ? color : game.theme.palette.elevatedSurface)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func buildNightReport() {
        let eliminatedIDs = killed.subtracting(protected)
        report = NightReport(
            eliminated: players(for: eliminatedIDs),
            saved: players(for: killed.intersection(protected)),
            silenced: players(for: blocked)
        )
        nightStage = .report
    }

    private func players(for ids: Set<UUID>) -> [GamePlayer] {
        game.players
            .filter { ids.contains($0.id) }
            .sorted { $0.number < $1.number }
    }

    private var nightReportPanel: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                if let report {
                    reportSection(
                        title: "Покинули игру",
                        icon: "xmark.circle.fill",
                        players: report.eliminated,
                        emptyText: "Ночью никто не погиб",
                        color: .red
                    )
                    reportSection(
                        title: "Спасены",
                        icon: "cross.case.fill",
                        players: report.saved,
                        emptyText: "Успешной защиты не было",
                        color: game.theme.palette.secondaryAccent
                    )
                    reportSection(
                        title: "Заглушены",
                        icon: "mic.slash.fill",
                        players: report.silenced,
                        emptyText: "Никто не лишён речи",
                        color: game.theme.palette.accent
                    )
                }

                Button {
                    applyNightReport()
                } label: {
                    Label("Вернуться к столу", systemImage: "person.3.fill")
                }
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
                .padding(.top, 4)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func reportSection(
        title: String,
        icon: String,
        players: [GamePlayer],
        emptyText: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Label(title.uppercased(), systemImage: icon)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(color)

            if players.isEmpty {
                Text(emptyText)
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
            } else {
                ForEach(players) { player in
                    HStack {
                        Text(String(format: "%02d", player.number))
                            .font(.caption.monospacedDigit().bold())
                            .foregroundStyle(color)
                        Text(player.displayName)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(player.role.name)
                            .font(.caption)
                            .foregroundStyle(game.theme.palette.secondaryText)
                    }
                }
            }
        }
        .mafiaCard(game.theme, padding: 14)
    }

    private func applyNightReport() {
        let eliminated = killed.subtracting(protected)
        game.finishNight(eliminatedIDs: eliminated, silencedIDs: blocked)
        killed.removeAll()
        protected.removeAll()
        blocked.removeAll()
        report = nil
        section = .overview
        nightStage = .neutral
    }

    private var timerPanel: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                VStack(spacing: 16) {
                    Text(timer.formatted)
                        .font(.system(size: 72, weight: .light, design: .monospaced))
                        .minimumScaleFactor(0.62)
                        .contentTransition(.numericText())

                    HStack(spacing: 10) {
                        Button {
                            timer.toggle(tone: game.endTone)
                        } label: {
                            Label(
                                timer.isRunning ? "Пауза" : "Старт",
                                systemImage: timer.isRunning ? "pause.fill" : "play.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(game.theme.palette.accent)

                        Button {
                            timer.reset(seconds: manualMinutes * 60 + manualSeconds)
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
                    SectionLabel("Основные интервалы")
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 9
                    ) {
                        preset("Переголосование · 0:30", seconds: 30)
                        preset("Речь · 1:00", seconds: 60)
                        preset("Последнее слово · 1:00", seconds: 60)
                        preset("Клубная · 1:30", seconds: 90)
                        preset("Обсуждение · 2:00", seconds: 120)
                        preset("Длинная · 3:00", seconds: 180)
                    }
                }
                .mafiaCard(game.theme)

                VStack(alignment: .leading, spacing: 14) {
                    SectionLabel("Точная настройка")
                    HStack(spacing: 12) {
                        timePicker("МИН", value: $manualMinutes, range: 0...15)
                        Text(":")
                            .font(.title.bold())
                            .foregroundStyle(game.theme.palette.secondaryText)
                        timePicker("СЕК", value: $manualSeconds, range: 0...59)
                    }
                    Button("Установить \(String(format: "%02d:%02d", manualMinutes, manualSeconds))") {
                        timer.reset(seconds: manualMinutes * 60 + manualSeconds)
                    }
                    .buttonStyle(.bordered)
                    .tint(game.theme.palette.accent)
                    .disabled(manualMinutes == 0 && manualSeconds == 0)
                }
                .mafiaCard(game.theme)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func preset(_ title: String, seconds: Int) -> some View {
        Button(title) {
            manualMinutes = seconds / 60
            manualSeconds = seconds % 60
            timer.reset(seconds: seconds)
        }
        .font(.caption.weight(.semibold))
        .frame(maxWidth: .infinity, minHeight: 42)
        .background(game.theme.palette.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        .buttonStyle(.plain)
    }

    private func timePicker(
        _ title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(game.theme.palette.secondaryText)
            Picker(title, selection: value) {
                ForEach(range, id: \.self) { item in
                    Text(String(format: "%02d", item)).tag(item)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 92)
            .clipped()
        }
        .frame(maxWidth: .infinity)
    }

    private var votePanel: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                if nominees.isEmpty {
                    Text("Добавляйте кандидатов в порядке выставления. Красная карточка автоматически исключает игрока из голосования.")
                        .font(.footnote)
                        .foregroundStyle(game.theme.palette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(Array(nominees.enumerated()), id: \.element) { index, id in
                        if let player = game.players.first(where: { $0.id == id }) {
                            voteRow(player, position: index + 1)
                        }
                    }
                }

                Menu {
                    ForEach(availableNominees) { player in
                        Button("\(player.number). \(player.displayName)") {
                            nominees.append(player.id)
                            voteCounts[player.id] = 0
                        }
                    }
                } label: {
                    Label("Добавить кандидата", systemImage: "person.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(game.theme.palette.accent)
                .disabled(availableNominees.isEmpty)

                if let leader = uniqueLeader {
                    Button {
                        game.eliminate(leader.id)
                        nominees.removeAll()
                        voteCounts.removeAll()
                    } label: {
                        Label("Исключить №\(leader.number)", systemImage: "gavel.fill")
                    }
                    .buttonStyle(LuxuryButtonStyle(theme: game.theme))
                }
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func voteRow(_ player: GamePlayer, position: Int) -> some View {
        HStack(spacing: 12) {
            Text("\(position)")
                .font(.caption.monospacedDigit().bold())
                .foregroundStyle(game.theme.palette.secondaryText)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(player.displayName)
                    .font(.subheadline.weight(.semibold))
                Text("Игрок №\(player.number)")
                    .font(.caption)
                    .foregroundStyle(game.theme.palette.secondaryText)
            }
            Spacer()
            Button {
                voteCounts[player.id] = max(0, (voteCounts[player.id] ?? 0) - 1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.bordered)
            .tint(game.theme.palette.text)

            Text("\(voteCounts[player.id] ?? 0)")
                .font(.title3.monospacedDigit().bold())
                .frame(width: 28)

            Button {
                voteCounts[player.id, default: 0] += 1
            } label: {
                Image(systemName: "plus")
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.borderedProminent)
            .tint(game.theme.palette.accent)
        }
        .mafiaCard(game.theme, padding: 12)
    }

    private var availableNominees: [GamePlayer] {
        game.players.filter {
            game.canVote($0) && !nominees.contains($0.id)
        }
    }

    private var uniqueLeader: GamePlayer? {
        guard let maximum = nominees.map({ voteCounts[$0] ?? 0 }).max(), maximum > 0 else {
            return nil
        }
        let leaders = nominees.filter { voteCounts[$0] == maximum }
        guard leaders.count == 1 else { return nil }
        return game.players.first { $0.id == leaders[0] }
    }

    private func toggle(_ id: UUID, in set: inout Set<UUID>) {
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
    }
}
