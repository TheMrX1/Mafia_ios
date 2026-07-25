import Foundation
import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var game: GameSession
    @State private var namesExpanded = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
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
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
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
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: mode == .sport ? "trophy.fill" : "theatermasks.fill")
                                Spacer()
                                Image(systemName: game.mode == mode ? "checkmark.circle.fill" : "circle")
                            }
                            .foregroundStyle(game.mode == mode ? game.theme.palette.accent : game.theme.palette.secondaryText)
                            Text(mode.title)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
                        .mafiaCard(game.theme, padding: 14)
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
                .font(.caption)
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
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.84)) {
                    namesExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(game.theme.palette.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Имена игроков")
                            .font(.headline)
                        Text(namesExpanded ? "Телефон пойдёт сверху вниз" : "\(game.playerCount) мест · можно оставить как есть")
                            .font(.caption)
                            .foregroundStyle(game.theme.palette.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(game.theme.palette.secondaryText)
                        .rotationEffect(.degrees(namesExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if namesExpanded {
                LazyVStack(spacing: 8) {
                    ForEach(game.playerNames.indices, id: \.self) { index in
                        HStack(spacing: 10) {
                            Text(String(format: "%02d", index + 1))
                                .font(.caption.monospacedDigit().bold())
                                .foregroundStyle(game.theme.palette.accent)
                                .frame(width: 24)
                            TextField("Игрок \(index + 1)", text: $game.playerNames[index])
                                .textInputAutocapitalization(.words)
                                .submitLabel(index + 1 == game.playerNames.count ? .done : .next)
                        }
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(game.theme.palette.elevatedSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
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
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(configuration.name)
                    .font(.system(size: 19, weight: .bold, design: .serif))
                    .fixedSize(horizontal: false, vertical: true)
                Text(configuration.note)
                    .font(.caption)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 7) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? game.theme.palette.accent : game.theme.palette.secondaryText)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Circle()
                            .fill(star <= configuration.stars ? game.theme.palette.accent : game.theme.palette.border)
                            .frame(width: 5, height: 5)
                    }
                }
            }
        }
        .mafiaCard(game.theme, padding: 14)
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
            LazyVStack(alignment: .leading, spacing: 20) {
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
                        text: "Передавайте iPhone по кругу. Каждый видит только свою карту."
                    )
                    RuleDivider()
                    RuleBlock(
                        number: "02",
                        icon: "quote.bubble.fill",
                        title: "Обсудите",
                        text: "Днём ищите противоречия, выдвигайте кандидатов и голосуйте."
                    )
                    RuleDivider()
                    RuleBlock(
                        number: "03",
                        icon: "moon.stars.fill",
                        title: "Проведите ночь",
                        text: "Включите музыку, выполните действия ролей и отметьте выбывших."
                    )
                }
                .mafiaCard(game.theme, padding: 4)

                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel("Роли в партии", detail: "\(uniqueRoles.count)")
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 10
                    ) {
                        ForEach(uniqueRoles) { role in
                            RoleBriefCard(role: role)
                        }
                    }
                }

                Button {
                    game.startReveal()
                } label: {
                    Label("Начать раздачу", systemImage: "rectangle.stack.fill")
                }
                .buttonStyle(LuxuryButtonStyle(theme: game.theme))
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
        HStack(spacing: 10) {
            Image(role.artwork)
                .resizable()
                .scaledToFill()
                .frame(width: 42, height: 42)
                .clipped()
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(role.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                Circle()
                    .fill(role.team == .mafia ? game.theme.palette.accent : game.theme.palette.secondaryAccent)
                    .frame(width: 5, height: 5)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mafiaCard(game.theme, padding: 10)
    }
}
