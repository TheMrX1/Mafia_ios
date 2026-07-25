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
    case velvet
    case midnight

    var id: String { rawValue }
    var title: String {
        switch self {
        case .neonNoir: "Неонуар"
        case .artDeco: "Ар-деко"
        case .minimal: "Минимализм"
        case .velvet: "Бархат"
        case .midnight: "Полночь"
        }
    }
}

enum CardSkin: String, CaseIterable, Identifiable, Hashable {
    case crown
    case monogram
    case eclipse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .crown: "Корона"
        case .monogram: "Монограмма"
        case .eclipse: "Затмение"
        }
    }

    var symbol: String {
        switch self {
        case .crown: "crown.fill"
        case .monogram: "suit.spade.fill"
        case .eclipse: "moonphase.new.moon"
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
    let artwork: String
    let summary: String
    let details: String
    let strategy: String
    let nightAction: String?

    var objective: String {
        switch id {
        case "citizen":
            "Вычислите мафию и помогите городу исключить её."
        case "sheriff":
            "Найдите мафию проверками и передайте городу факты."
        case "doctor":
            "Сохраняйте ключевых игроков в живых."
        case "mafia":
            "Останьтесь в большинстве и подчините себе город."
        case "don":
            "Управляйте мафией и найдите шерифа."
        case "maniac":
            "Переживите всех и останьтесь последним."
        case "mistress":
            "Срывайте ночные действия опасных ролей."
        default:
            summary
        }
    }

    static let citizen = Role(
        id: "citizen", name: "Мирный житель", team: .city, icon: "person.fill", artwork: "RoleCitizen",
        summary: "Вы — голос города. Наблюдайте, обсуждайте и вычисляйте тех, кто скрывается среди мирных.",
        details: "У вас нет ночного действия, зато днём ваш голос равен голосу любого специального персонажа. Победа приходит, когда город исключит всю мафию и нейтральных убийц.",
        strategy: "Сравнивайте слова с голосованиями. Задавайте конкретные вопросы и не бойтесь менять мнение, если появились новые факты.",
        nightAction: nil
    )
    static let sheriff = Role(
        id: "sheriff", name: "Шериф", team: .city, icon: "shield.fill", artwork: "RoleSheriff",
        summary: "Вы ведёте расследование. Каждую ночь узнавайте, связан ли выбранный игрок с мафией.",
        details: "Днём вы участвуете в обсуждении как обычный горожанин. Ночью ведущий показывает результат одной проверки. Город побеждает, когда опасные роли устранены.",
        strategy: "Не раскрывайтесь слишком рано. Соберите несколько проверок и заранее решите, кому сможете безопасно передать информацию.",
        nightAction: "Выберите игрока для проверки."
    )
    static let doctor = Role(
        id: "doctor", name: "Доктор", team: .city, icon: "cross.case.fill", artwork: "RoleDoctor",
        summary: "Вы защищаете город. Каждую ночь выберите игрока, которого хотите спасти от покушения.",
        details: "Если мафия или маньяк атакуют выбранного вами игрока, он переживает ночь. Ограничения на самолечение и повторное лечение определяются правилами вашей компании.",
        strategy: "Следите, кто стал важной целью после дневной дискуссии. Иногда лучший ход — защитить не самого громкого, а самого убедительного игрока.",
        nightAction: "Выберите игрока для лечения."
    )
    static let mafia = Role(
        id: "mafia", name: "Мафия", team: .mafia, icon: "suit.spade.fill", artwork: "RoleMafia",
        summary: "Вы — часть теневой команды. Днём смешивайтесь с городом, ночью совместно выбирайте жертву.",
        details: "Вы знаете своих союзников. Мафия побеждает, когда её численность становится не меньше числа остальных живых игроков.",
        strategy: "Не защищайте союзников слишком очевидно. Создавайте правдоподобную позицию и заранее согласуйте логику голосования.",
        nightAction: "Вместе с мафией выберите цель."
    )
    static let don = Role(
        id: "don", name: "Дон", team: .mafia, icon: "crown.fill", artwork: "RoleDon",
        summary: "Вы возглавляете мафию, участвуете в выборе жертвы и по ночам разыскиваете шерифа.",
        details: "Дон играет за чёрную команду и знает остальных мафиози. В спортивной версии отдельной проверкой пытается определить шерифа.",
        strategy: "Управляйте командой незаметно. Сохраняйте спокойствие и используйте поиск шерифа, чтобы убрать главную угрозу в подходящий момент.",
        nightAction: "Выберите игрока для поиска шерифа."
    )
    static let maniac = Role(
        id: "maniac", name: "Маньяк", team: .neutral, icon: "moon.fill", artwork: "RoleManiac",
        summary: "Вы играете только за себя. Ночью выбирайте цель и постарайтесь остаться последним выжившим.",
        details: "Вы не принадлежите ни городу, ни мафии. Ваш точный порядок хода и взаимодействие с доктором определяются выбранными правилами.",
        strategy: "Временно помогайте стороне, которая проигрывает: так обе команды дольше будут заняты друг другом, а не вами.",
        nightAction: "Выберите свою цель."
    )
    static let mistress = Role(
        id: "mistress", name: "Красотка", team: .city, icon: "sparkles", artwork: "RoleMistress",
        summary: "Вы сбиваете чужие планы. Ночью выбранный вами игрок не может выполнить своё действие.",
        details: "Заблокированы могут быть как опасные, так и полезные роли, поэтому каждый визит — риск. Обычно нельзя выбирать одного игрока две ночи подряд.",
        strategy: "Сопоставляйте ночные события с поведением игроков. Удачная блокировка может подтвердить подозрение без прямой проверки.",
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

enum GamePhase: Hashable {
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
