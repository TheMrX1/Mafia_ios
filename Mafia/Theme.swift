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
        case .velvet:
            ThemePalette(
                background: Color(red: 0.045, green: 0.008, blue: 0.014),
                secondaryBackground: Color(red: 0.12, green: 0.018, blue: 0.03),
                surface: Color(red: 0.13, green: 0.025, blue: 0.04).opacity(0.91),
                elevatedSurface: Color(red: 0.18, green: 0.038, blue: 0.055).opacity(0.96),
                text: Color(red: 1, green: 0.95, blue: 0.90),
                secondaryText: Color(red: 0.80, green: 0.69, blue: 0.66),
                accent: Color(red: 0.88, green: 0.65, blue: 0.34),
                secondaryAccent: Color(red: 0.76, green: 0.15, blue: 0.23),
                border: Color(red: 0.88, green: 0.65, blue: 0.34).opacity(0.28),
                buttonText: Color(red: 0.12, green: 0.025, blue: 0.03),
                prefersDark: true
            )
        case .midnight:
            ThemePalette(
                background: Color(red: 0.008, green: 0.025, blue: 0.055),
                secondaryBackground: Color(red: 0.016, green: 0.06, blue: 0.12),
                surface: Color(red: 0.025, green: 0.075, blue: 0.14).opacity(0.90),
                elevatedSurface: Color(red: 0.035, green: 0.105, blue: 0.19).opacity(0.96),
                text: Color(red: 0.93, green: 0.97, blue: 1),
                secondaryText: Color(red: 0.65, green: 0.74, blue: 0.84),
                accent: Color(red: 0.42, green: 0.78, blue: 1),
                secondaryAccent: Color(red: 0.60, green: 0.56, blue: 1),
                border: Color(red: 0.55, green: 0.78, blue: 1).opacity(0.24),
                buttonText: Color(red: 0.015, green: 0.05, blue: 0.10),
                prefersDark: true
            )
        }
    }

    var backgroundImage: String {
        switch self {
        case .neonNoir: "BackgroundNeon"
        case .artDeco: "BackgroundDeco"
        case .minimal: "BackgroundMinimal"
        case .velvet: "BackgroundDeco"
        case .midnight: "BackgroundNeon"
        }
    }

    var backgroundTint: Color {
        switch self {
        case .velvet: Color(red: 0.72, green: 0.16, blue: 0.19)
        case .midnight: Color(red: 0.25, green: 0.48, blue: 0.86)
        default: .white
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .neonNoir: 24
        case .artDeco: 8
        case .minimal: 20
        case .velvet: 18
        case .midnight: 22
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
        ZStack {
            theme.palette.background
                .ignoresSafeArea()

            Image(theme.backgroundImage)
                .resizable()
                .scaledToFill()
                .colorMultiply(theme.backgroundTint)
                .ignoresSafeArea()

            LinearGradient(
                colors: backgroundOverlay,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .foregroundStyle(theme.palette.text)
        .animation(.easeInOut(duration: 0.45), value: theme)
    }

    private var backgroundOverlay: [Color] {
        switch theme {
        case .minimal:
            [Color.white.opacity(0.10), Color.white.opacity(0.54)]
        case .neonNoir:
            [Color.black.opacity(0.18), Color.black.opacity(0.64)]
        case .artDeco:
            [Color.black.opacity(0.22), Color.black.opacity(0.68)]
        case .velvet:
            [Color.black.opacity(0.18), Color.black.opacity(0.64)]
        case .midnight:
            [Color.black.opacity(0.12), Color.black.opacity(0.62)]
        }
    }
}

struct MafiaCard: ViewModifier {
    let theme: AppTheme
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    .fill(theme.palette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                theme.palette.border.opacity(1.2),
                                theme.palette.border.opacity(0.34)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: theme == .artDeco ? 1.25 : 0.8
                    )
            }
            .shadow(
                color: theme == .minimal ? Color.black.opacity(0.055) : Color.black.opacity(0.22),
                radius: 18,
                y: 9
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
                .font(.system(size: 32, weight: .bold, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 48)
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

struct LuxuryButtonStyle: ButtonStyle {
    let theme: AppTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(theme.palette.buttonText)
            .background {
                RoundedRectangle(cornerRadius: theme == .artDeco ? 10 : 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.palette.accent.opacity(configuration.isPressed ? 0.82 : 1),
                                theme.palette.accent.opacity(configuration.isPressed ? 0.66 : 0.78)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: theme == .artDeco ? 10 : 18, style: .continuous)
                            .stroke(Color.white.opacity(0.20), lineWidth: 0.7)
                    }
            }
            .shadow(
                color: theme.palette.accent.opacity(configuration.isPressed ? 0.10 : 0.25),
                radius: configuration.isPressed ? 6 : 16,
                y: configuration.isPressed ? 3 : 8
            )
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.spring(response: 0.26, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

extension View {
    func mafiaCard(_ theme: AppTheme, padding: CGFloat = 16) -> some View {
        modifier(MafiaCard(theme: theme, padding: padding))
    }

    func contentColumn() -> some View {
        frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
    }
}

extension AnyTransition {
    static var premiumScene: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .scale(scale: 1.015))
                .combined(with: .offset(y: 14)),
            removal: .opacity
                .combined(with: .scale(scale: 0.985))
                .combined(with: .offset(y: -10))
        )
    }
}
