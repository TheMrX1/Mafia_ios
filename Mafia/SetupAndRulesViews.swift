import Foundation
import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 26) {
                ScreenHeader(
                    "Private club",
                    title: "Город засыпает",
                    subtitle: "Создайте партию. Остальное приложение возьмёт на себя."
                )

                modeSelector

                if game.mode == .classic {
                    playerCountCard
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel("Сценарий", detail: "\(game.configurations.count) вариантов")
                    ForEach(game.configurations) { config in
                        Button {
                            withAnimation(.snappy) {
                                game.selectedConfigurationID = config.id
                            }
                        } label: {
                            ConfigurationRow(
                                configuration: config,
                                selected: game.selectedConfiguration.id == config.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                namesCard

                Button {
                    game.prepareGame()
                } label: {
                    Label("Перейти к правилам", systemImage: "arrow.right")
                }
                .primaryButton(game.theme)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Формат игры")
            HStack(spacing: 10) {
                ForEach(GameMode.allCases) { mode in
                    Button {
                        withAnimation(.snappy) {
                            game.changeMode(mode)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Image(systemName: mode == .sport ? "trophy.fill" : "theatermasks.fill")
                                Spacer()
                                Image(systemName: game.mode == mode ? "checkmark.circle.fill" : "circle")
                            }
                            .foregroundStyle(game.mode == mode ? game.theme.palette.accent : game.theme.palette.secondaryText)
                            Text(mode.title)
                                .font(.headline)
                            Text(mode == .sport ? "Турнирные правила" : "Роли и сценарии")
                                .font(.caption)
                                .foregroundStyle(game.theme.palette.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
                        .mafiaCard(game.theme, padding: 15)
                        .overlay {
                            if game.mode == mode {
                                RoundedRectangle(cornerRadius: game.theme.cornerRadius, style: .continuous)
                                    .stroke(game.theme.palette.accent.opacity(0.72), lineWidth: 1.5)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(game.mode.subtitle)
                .font(.footnote)
                .foregroundStyle(game.theme.palette.secondaryText)
        }
    }

    private var playerCountCard: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel("Игроки")
                Text("\(game.playerCount)")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(game.theme.palette.accent)
            }
            Spacer()
            Stepper(
                "Количество игроков",
                value: Binding(
                    get: { game.playerCount },
                    set: { game.setPlayerCount($0) }
                ),
                in: 6...16
            )
            .labelsHidden()
            .tint(game.theme.palette.accent)
        }
        .mafiaCard(game.theme)
    }

    private var namesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("Порядок игроков", detail: "\(game.playerCount)")
            Text("Телефон будет передаваться сверху вниз.")
                .font(.footnote)
                .foregroundStyle(game.theme.palette.secondaryText)

            LazyVStack(spacing: 10) {
                ForEach(game.playerNames.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        Text(String(format: "%02d", index + 1))
                            .font(.caption.monospacedDigit().bold())
                            .foregroundStyle(game.theme.palette.accent)
                            .frame(width: 26)
                        TextField("Игрок \(index + 1)", text: $game.playerNames[index])
                            .textInputAutocapitalization(.words)
                            .submitLabel(index + 1 == game.playerNames.count ? .done : .next)
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 48)
                    .background(game.theme.palette.elevatedSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(game.theme.palette.border, lineWidth: 1)
                    }
                }
            }
        }
        .mafiaCard(game.theme)
    }
}

private struct ConfigurationRow: View {
    @EnvironmentObject private var game: GameSession
    let configuration: GameConfiguration
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(configuration.name)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(configuration.note)
                        .font(.subheadline)
                        .foregroundStyle(game.theme.palette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? game.theme.palette.accent : game.theme.palette.secondaryText)
            }

            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= configuration.stars ? "star.fill" : "star")
                        .font(.caption2)
                }
                Text("сложность")
                    .font(.caption)
                    .padding(.leading, 5)
            }
            .foregroundStyle(game.theme.palette.accent)

            Divider().overlay(game.theme.palette.border)

            Text(configuration.roleSummary)
                .font(.caption)
                .foregroundStyle(game.theme.palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .mafiaCard(game.theme)
        .overlay {
            if selected {
                RoundedRectangle(cornerRadius: game.theme.cornerRadius, style: .continuous)
                    .stroke(game.theme.palette.accent.opacity(0.72), lineWidth: 1.5)
            }
        }
    }
}

struct RulesView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ScreenHeader(
                    "Брифинг",
                    title: "Перед началом",
                    subtitle: game.mode == .sport
                        ? "Спортивная мафия · 10 игроков"
                        : "Обычная мафия · \(game.playerCount) игроков"
                )

                VStack(spacing: 0) {
                    RuleBlock(
                        number: "01",
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Получите роль",
                        text: "Передавайте iPhone по кругу. Каждый игрок открывает только свою карточку и скрывает её перед передачей."
                    )
                    RuleDivider()
                    RuleBlock(
                        number: "02",
                        icon: "quote.bubble.fill",
                        title: "Обсуждайте днём",
                        text: game.mode == .sport
                            ? "Говорите по очереди, используйте таймер, выдвигайте кандидатов и голосуйте. Следите не только за словами, но и за решениями игроков."
                            : "Обсуждайте поведение игроков, делитесь подозрениями и голосуйте за исключение. У каждой роли своя цель, но днём все выглядят одинаково."
                    )
                    RuleDivider()
                    RuleBlock(
                        number: "03",
                        icon: "moon.stars.fill",
                        title: "Действуйте ночью",
                        text: "Включите музыку, закройте глаза и последовательно выполните действия ролей. После ночи отметьте выбывших в приложении."
                    )
                }
                .mafiaCard(game.theme, padding: 4)

                VStack(alignment: .leading, spacing: 14) {
                    SectionLabel("Досье ролей", detail: "\(uniqueRoles.count)")
                    ForEach(uniqueRoles) { role in
                        RoleBriefCard(role: role)
                    }
                }

                Button {
                    game.startReveal()
                } label: {
                    Label("Начать раздачу", systemImage: "rectangle.stack.fill")
                }
                .primaryButton(game.theme)
            }
            .contentColumn()
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 52)
        }
    }

    private var uniqueRoles: [Role] {
        Array(Set(game.selectedConfiguration.roles))
            .sorted { $0.name < $1.name }
    }
}

private struct RuleDivider: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        Divider()
            .overlay(game.theme.palette.border)
            .padding(.leading, 68)
    }
}

private struct RuleBlock: View {
    @EnvironmentObject private var game: GameSession
    let number: String
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(game.theme.palette.accent.opacity(0.14))
                Image(systemName: icon)
                    .foregroundStyle(game.theme.palette.accent)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title).font(.headline)
                    Spacer()
                    Text(number)
                        .font(.caption.monospacedDigit().bold())
                        .foregroundStyle(game.theme.palette.accent)
                }
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(15)
    }
}

private struct RoleBriefCard: View {
    @EnvironmentObject private var game: GameSession
    let role: Role

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(role.artwork)
                .resizable()
                .scaledToFill()
                .frame(width: 78, height: 94)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(role.team.title)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(game.theme.palette.accent)
                Text(role.name)
                    .font(.headline)
                Text(role.summary)
                    .font(.caption)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mafiaCard(game.theme, padding: 12)
    }
}