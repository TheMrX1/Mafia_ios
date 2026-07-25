import SwiftUI

private enum HostSection: String, CaseIterable, Identifiable {
    case night
    case timer
    case vote

    var id: String { rawValue }

    var title: String {
        switch self {
        case .night: "Ночь"
        case .timer: "Таймер"
        case .vote: "Голосование"
        }
    }

    var icon: String {
        switch self {
        case .night: "moon.stars.fill"
        case .timer: "timer"
        case .vote: "hand.raised.fill"
        }
    }
}

struct HostView: View {
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var timer: DayCountdown
    @State private var section: HostSection = .night
    @State private var killed: Set<UUID> = []
    @State private var protected: Set<UUID> = []
    @State private var blocked: Set<UUID> = []
    @State private var nominees: [UUID] = []
    @State private var voteCounts: [UUID: Int] = [:]
    @State private var manualMinutes = 1
    @State private var manualSeconds = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ПУЛЬТ ВЕДУЩЕГО")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(2.5)
                        .foregroundStyle(game.theme.palette.accent)
                    Text("Раунд \(game.round)")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                }
                Spacer()
                Text("\(game.alivePlayers.count) в игре")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .padding(.trailing, 48)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Group {
                switch section {
                case .night:
                    nightPanel
                case .timer:
                    timerPanel
                case .vote:
                    votePanel
                }
            }
            .id(section)
            .transition(.opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            sectionBar
        }
        .animation(.easeOut(duration: 0.18), value: section)
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

    private var nightPanel: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                Text("Роли видит только ведущий. Отметки сохраняются при переходе между разделами.")
                    .font(.footnote)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(game.players) { player in
                    hostRoleCard(player)
                }

                Button {
                    let eliminated = killed.subtracting(protected)
                    killed.removeAll()
                    protected.removeAll()
                    blocked.removeAll()
                    game.finishNight(eliminatedIDs: eliminated)
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

    private func hostRoleCard(_ player: GamePlayer) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(player.role.artwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
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
                Spacer()
                if !player.isAlive {
                    Text("ВЫБЫЛ")
                        .font(.caption2.bold())
                        .foregroundStyle(game.theme.palette.secondaryText)
                }
            }

            if player.isAlive {
                HStack(spacing: 8) {
                    nightAction("Убить", icon: "scope", active: killed.contains(player.id), color: .red) {
                        toggle(player.id, in: &killed)
                    }
                    nightAction("Спасти", icon: "cross.case.fill", active: protected.contains(player.id), color: game.theme.palette.secondaryAccent) {
                        toggle(player.id, in: &protected)
                    }
                    nightAction("Блок", icon: "nosign", active: blocked.contains(player.id), color: game.theme.palette.accent) {
                        toggle(player.id, in: &blocked)
                    }
                }
            }
        }
        .mafiaCard(game.theme, padding: 12)
        .opacity(player.isAlive ? 1 : 0.52)
    }

    private func nightAction(
        _ title: String,
        icon: String,
        active: Bool,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption2.weight(.bold))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .foregroundStyle(active ? Color.white : game.theme.palette.secondaryText)
                .background(active ? color : game.theme.palette.elevatedSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
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
                            Label(timer.isRunning ? "Пауза" : "Старт", systemImage: timer.isRunning ? "pause.fill" : "play.fill")
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
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                        preset("30 секунд", seconds: 30)
                        preset("Речь · 1:00", seconds: 60)
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
        .frame(maxWidth: .infinity, minHeight: 38)
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
                    Text("Добавляйте кандидатов в том порядке, в котором их выставили. Этот порядок не изменится при подсчёте.")
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
        game.alivePlayers.filter { !nominees.contains($0.id) }
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
