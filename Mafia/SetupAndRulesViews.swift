import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("MAFIA")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .tracking(7)
                        .foregroundStyle(game.theme.palette.accent)
                    Text("Город засыпает.")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("Соберите компанию, выберите сценарий — приложение проведёт вас через игру.")
                        .foregroundStyle(game.theme.palette.secondaryText)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Режим").font(.headline)
                    Picker("Режим", selection: Binding(
                        get: { game.mode },
                        set: { game.changeMode($0) }
                    )) {
                        ForEach(GameMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(game.mode.subtitle)
                        .font(.footnote)
                        .foregroundStyle(game.theme.palette.secondaryText)
                }
                .mafiaCard(game.theme)

                if game.mode == .classic {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Игроки").font(.headline)
                            Spacer()
                            Text("\(game.playerCount)")
                                .font(.title2.bold())
                                .foregroundStyle(game.theme.palette.accent)
                        }
                        Stepper(
                            "Количество игроков",
                            value: Binding(
                                get: { game.playerCount },
                                set: { game.setPlayerCount($0) }
                            ),
                            in: 6...16
                        )
                        .labelsHidden()
                    }
                    .mafiaCard(game.theme)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Сценарий").font(.headline)
                    ForEach(game.configurations) { config in
                        Button {
                            game.selectedConfigurationID = config.id
                        } label: {
                            ConfigurationRow(
                                configuration: config,
                                selected: game.selectedConfiguration.id == config.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Имена игроков").font(.headline)
                    Text("Телефон будет передаваться в этом порядке.")
                        .font(.footnote)
                        .foregroundStyle(game.theme.palette.secondaryText)
                    ForEach(game.playerNames.indices, id: \.self) { index in
                        TextField(
                            "Игрок \(index + 1)",
                            text: $game.playerNames[index]
                        )
                        .textFieldStyle(.plain)
                        .padding(13)
                        .background(game.theme.palette.background.opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .mafiaCard(game.theme)

                Button("Объяснить правила") {
                    game.prepareGame()
                }
                .primaryButton(game.theme)
            }
            .padding(20)
            .padding(.bottom, 32)
        }
    }
}

private struct ConfigurationRow: View {
    @EnvironmentObject private var game: GameSession
    let configuration: GameConfiguration
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(configuration.name).font(.headline)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= configuration.stars ? "star.fill" : "star")
                            .font(.caption2)
                    }
                }
                .foregroundStyle(game.theme.palette.accent)
            }
            Text(configuration.note)
                .font(.subheadline)
                .foregroundStyle(game.theme.palette.secondaryText)
            Text(configuration.roleSummary)
                .font(.caption)
                .foregroundStyle(game.theme.palette.secondaryText)
                .lineLimit(3)
        }
        .mafiaCard(game.theme)
        .overlay(alignment: .topTrailing) {
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(game.theme.palette.secondaryAccent)
                    .padding(10)
            }
        }
    }
}

struct RulesView: View {
    @EnvironmentObject private var game: GameSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Как играть")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text(game.mode == .sport ? "Правила спортивной мафии" : "Правила обычной мафии")
                    .foregroundStyle(game.theme.palette.accent)

                RuleBlock(
                    number: "01",
                    title: "Получите роль",
                    text: "Передавайте iPhone по кругу. Каждый игрок открывает только свою карточку и скрывает её перед передачей."
                )
                RuleBlock(
                    number: "02",
                    title: "Обсуждайте днём",
                    text: game.mode == .sport
                        ? "Игроки говорят по очереди. Используйте таймер, выдвигайте кандидатов и голосуйте."
                        : "Обсуждайте поведение игроков, выдвигайте подозреваемых и голосуйте за исключение."
                )
                RuleBlock(
                    number: "03",
                    title: "Действуйте ночью",
                    text: "Включите музыку, закройте глаза и выполняйте действия ролей. После ночи отметьте выбывших."
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Роли в этой игре").font(.headline)
                    ForEach(Array(Set(game.selectedConfiguration.roles)).sorted(by: { $0.name < $1.name })) { role in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: role.icon)
                                .frame(width: 24)
                                .foregroundStyle(game.theme.palette.accent)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(role.name).font(.headline)
                                Text(role.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(game.theme.palette.secondaryText)
                            }
                        }
                    }
                }
                .mafiaCard(game.theme)

                Button("Начать раздачу ролей") {
                    game.startReveal()
                }
                .primaryButton(game.theme)
            }
            .padding(20)
            .padding(.bottom, 30)
        }
    }
}

private struct RuleBlock: View {
    @EnvironmentObject private var game: GameSession
    let number: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.title2.bold())
                .foregroundStyle(game.theme.palette.accent)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
            }
        }
    }
}
