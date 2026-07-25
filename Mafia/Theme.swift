import SwiftUI

struct ThemePalette {
    let background: Color
    let secondaryBackground: Color
    let surface: Color
    let elevatedSurface: Color
    let text: Color
    let secondaryText: Color
    let accent: Color
    let secondaryAccent: Color
    let border: Color
    let buttonText: Color
    let prefersDark: Bool
}

extension AppTheme {
    var palette: ThemePalette {
        switch self {
        case .neonNoir:
            ThemePalette(
                background: Color(red: 0.015, green: 0.012, blue: 0.035),
                secondaryBackground: Color(red: 0.065, green: 0.025, blue: 0.09),
                surface: Color(red: 0.07, green: 0.06, blue: 0.12).opacity(0.78),
                elevatedSurface: Color(red: 0.105, green: 0.085, blue: 0.17).opacity(0.92),
                text: Color(red: 0.98, green: 0.97, blue: 1),
                secondaryText: Color(red: 0.76, green: 0.73, blue: 0.82),
                accent: Color(red: 1, green: 0.24, blue: 0.57),
                secondaryAccent: Color(red: 0.24, green: 0.87, blue: 0.92),
                border: Color.white.opacity(0.13),
                buttonText: Color(red: 0.08, green: 0.015, blue: 0.05),
                prefersDark: true
            )
        case .artDeco:
            ThemePalette(
                background: Color(red: 0.018, green: 0.055, blue: 0.052),
                secondaryBackground: Color(red: 0.035, green: 0.105, blue: 0.09),
                surface: Color(red: 0.035, green: 0.09, blue: 0.08).opacity(0.88),
                elevatedSurface: Color(red: 0.055, green: 0.13, blue: 0.11).opacity(0.94),
                text: Color(red: 0.98, green: 0.94, blue: 0.82),
                secondaryText: Color(red: 0.79, green: 0.75, blue: 0.64),
                accent: Color(red: 0.89, green: 0.71, blue: 0.36),
                secondaryAccent: Color(red: 0.55, green: 0.84, blue: 0.69),
                border: Color(red: 0.89, green: 0.71, blue: 0.36).opacity(0.34),
                buttonText: Color(red: 0.055, green: 0.08, blue: 0.065),
                prefersDark: true
            )
        case .minimal:
            ThemePalette(
                background: Color(red: 0.94, green: 0.92, blue: 0.88),
                secondaryBackground: Color(red: 0.98, green: 0.97, blue: 0.94),
                surface: Color.white.opacity(0.76),
                elevatedSurface: Color.white.opacity(0.94),
                text: Color(red: 0.10, green: 0.095, blue: 0.09),
                secondaryText: Color(red: 0.39, green: 0.37, blue: 0.34),
                accent: Color(red: 0.43, green: 0.055, blue: 0.08),
                secondaryAccent: Color(red: 0.12, green: 0.31, blue: 0.29),
                border: Color.black.opacity(0.09),
                buttonText: .white,
                prefersDark: false
            )
        }
    }

    var backgroundImage: String {
        switch self {
        case .neonNoir: "BackgroundNeon"
        case .artDeco: "BackgroundDeco"
        case .minimal: "BackgroundMinimal"
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .neonNoir: 24
        case .artDeco: 8
        case .minimal: 20
        }
    }
}

extension Team {
    var title: String {
        switch self {
        case .city: "КОМАНДА ГОРОДА"
        case .mafia: "КОМАНДА МАФИИ"
        case .neutral: "НЕЙТРАЛЬНАЯ РОЛЬ"
        }
    }
}

struct ThemedBackground<Content: View>: View {
    let theme: AppTheme
    let content: Content

    init(theme: AppTheme, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image(theme.backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .ignoresSafeArea()

                LinearGradient(
                    colors: backgroundOverlay,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                content
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .background(theme.palette.background)
        .foregroundStyle(theme.palette.text)
    }

    private var backgroundOverlay: [Color] {
        switch theme {
        case .minimal:
            [Color.white.opacity(0.10), Color.white.opacity(0.54)]
        case .neonNoir:
            [Color.black.opacity(0.18), Color.black.opacity(0.64)]
        case .artDeco:
            [Color.black.opacity(0.22), Color.black.opacity(0.68)]
        }
    }
}

struct MafiaCard: ViewModifier {
    let theme: AppTheme
    var padding: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(theme.palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    .stroke(theme.palette.border, lineWidth: theme == .artDeco ? 1.5 : 1)
            }
            .shadow(
                color: theme == .minimal ? Color.black.opacity(0.06) : Color.black.opacity(0.28),
                radius: 24,
                y: 12
            )
    }
}

struct ScreenHeader: View {
    @EnvironmentObject private var game: GameSession
    let eyebrow: String
    let title: String
    let subtitle: String?

    init(_ eyebrow: String, title: String, subtitle: String? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(eyebrow.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(3.4)
                .foregroundStyle(game.theme.palette.accent)
            Text(title)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct SectionLabel: View {
    @EnvironmentObject private var game: GameSession
    let text: String
    let detail: String?

    init(_ text: String, detail: String? = nil) {
        self.text = text
        self.detail = detail
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(text.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.8)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(game.theme.palette.accent)
            }
        }
        .foregroundStyle(game.theme.palette.secondaryText)
    }
}

struct RoleArtwork: View {
    @EnvironmentObject private var game: GameSession
    let role: Role
    var height: CGFloat = 280

    var body: some View {
        Image(role.artwork)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, game.theme.palette.background.opacity(0.82)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: game.theme.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: game.theme.cornerRadius, style: .continuous)
                    .stroke(game.theme.palette.border, lineWidth: 1)
            }
    }
}

extension View {
    func mafiaCard(_ theme: AppTheme, padding: CGFloat = 18) -> some View {
        modifier(MafiaCard(theme: theme, padding: padding))
    }

    func primaryButton(_ theme: AppTheme) -> some View {
        self
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .foregroundStyle(theme.palette.buttonText)
            .background(
                LinearGradient(
                    colors: [theme.palette.accent, theme.palette.accent.opacity(0.78)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: theme == .artDeco ? 8 : 18, style: .continuous))
            .shadow(color: theme.palette.accent.opacity(0.22), radius: 14, y: 7)
    }

    func contentColumn() -> some View {
        frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
    }
}