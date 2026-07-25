import SwiftUI

enum GameMode: String, CaseIterable, Identifiable, Hashable {
    case sport
    case classic

    var id: String { rawValue }
    var title: String { self == .sport ? "Спортивная" : "Обычная" }
    var subtitle: String {
        self == .sport
            ? "10 игроков · фиксированный состав"
            : "6–16 игроков · наборы ролей"
    }
}

enum AppTheme: String, CaseIterable, Identifiable, Hashable {
    case neonNoir
    case artDeco
    case minimal

    var id: String { rawValue }
    var title: String {
        switch self {
        case .neonNoir: "Неонуар"
        case .artDeco: "Ар-деко"
        case .minimal: "Минимализм"
        }
    }
}

enum Team: String, Codable, Hashable {
    case city
    case mafia
    case neutral
}

struct Role: Identifiable, Hashable {
    let id: String
    let name: String
    let team: Team
    let icon: String
    let summary: String
    let nightAction: String?

    static let citizen = Role(
        id: "citizen", name: "Мирный житель", team: .city, icon: "person.fill",
        summary: "Найдите мафию с помощью обсуждений и голосования.",
        nightAction: nil
    )
    static let sheriff = Role(
        id: "sheriff", name: "Шериф", team: .city, icon: "shield.fill",
        summary: "Играете за город и ночью проверяете одного игрока.",
        nightAction: "Выберите игрока для проверки."
    )
    static let doctor = Role(
        id: "doctor", name: "Доктор", team: .city, icon: "cross.case.fill",
        summary: "Каждую ночь можете спасти одного игрока.",
        nightAction: "Выберите игрока для лечения."
    )
    static let mafia = Role(
        id: "mafia", name: "Мафия", team: .mafia, icon: "suit.spade.fill",
        summary: "Скрывайтесь среди мирных и устраняйте город ночью.",
        nightAction: "Вместе с мафией выберите цель."
    )
    static let don = Role(
        id: "don", name: "Дон", team: .mafia, icon: "crown.fill",
        summary: "Возглавляете мафию и ищете шерифа.",
        nightAction: "Выберите игрока для поиска шерифа."
    )
    static let maniac = Role(
        id: "maniac", name: "Маньяк", team: .neutral, icon: "moon.fill",
        summary: "Играете в одиночку. Победите, оставшись последним.",
        nightAction: "Выберите свою цель."
    )
    static let mistress = Role(
        id: "mistress", name: "Красотка", team: .city, icon: "sparkles",
        summary: "Ночью блокируете действие выбранного игрока.",
        nightAction: "Выберите игрока, который пропустит действие."
    )
}

struct GameConfiguration: Identifiable, Hashable {
    let id: String
    let name: String
    let stars: Int
    let note: String
    let roles: [Role]

    var roleSummary: String {
        Dictionary(grouping: roles, by: \.name)
            .map { "\($0.value.count)× \($0.key)" }
            .sorted()
            .joined(separator: " · ")
    }

    static let sport = GameConfiguration(
        id: "sport-10",
        name: "Спортивная десятка",
        stars: 4,
        note: "Классический турнирный состав",
        roles: [.don, .mafia, .mafia, .sheriff] + Array(repeating: .citizen, count: 6)
    )

    static func classic(playerCount count: Int) -> [GameConfiguration] {
        let mafiaCount = max(1, count / 4)

        func fill(_ special: [Role]) -> [Role] {
            let used = mafiaCount + special.count
            return Array(repeating: .mafia, count: mafiaCount)
                + special
                + Array(repeating: .citizen, count: max(0, count - used))
        }

        var result = [
            GameConfiguration(
                id: "balanced-\(count)",
                name: "Сбалансированная",
                stars: count < 9 ? 2 : 3,
                note: "Понятные роли, хороший первый матч",
                roles: fill([.sheriff, .doctor])
            )
        ]

        if count >= 8 {
            result.append(
                GameConfiguration(
                    id: "detective-\(count)",
                    name: "Острые ощущения",
                    stars: 4,
                    note: "Маньяк добавляет третью сторону",
                    roles: fill([.sheriff, .doctor, .maniac])
                )
            )
        }

        if count >= 10 {
            let black = max(1, mafiaCount - 1)
            let special: [Role] = [.don] + Array(repeating: .mafia, count: black)
                + [.sheriff, .doctor, .maniac, .mistress]
            let roles = special + Array(repeating: .citizen, count: max(0, count - special.count))
            result.append(
                GameConfiguration(
                    id: "full-\(count)",
                    name: "Полный город",
                    stars: 5,
                    note: "Много ночных действий и сложных решений",
                    roles: roles
                )
            )
        }
        return result
    }
}

struct GamePlayer: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    var name: String
    var role: Role
    var isAlive = true

    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Игрок \(number)"
            : name
    }
}

enum GamePhase: Equatable {
    case setup
    case rules
    case reveal
    case day
    case vote
    case night
    case summary
}

enum EndTone: String, CaseIterable, Identifiable, Hashable {
    case bell
    case signal
    case glass

    var id: String { rawValue }
    var title: String {
        switch self {
        case .bell: "Колокол"
        case .signal: "Сигнал"
        case .glass: "Стекло"
        }
    }
    var soundID: UInt32 {
        switch self {
        case .bell: 1005
        case .signal: 1013
        case .glass: 1054
        }
    }
}
