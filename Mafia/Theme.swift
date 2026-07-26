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
    let wallpaper: Wallpaper
    let content: Content

    init(
        theme: AppTheme,
        wallpaper: Wallpaper,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.wallpaper = wallpaper
        self.content = content()
    }

    var body: some View {
        ZStack {
            theme.palette.background
                .ignoresSafeArea()

            Image(wallpaper.artwork)
                .resizable()
                .scaledToFill()
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var backgroundOverlay: [Color] {
        switch wallpaper {
        case .editorial:
            [Color.white.opacity(0.10), Color.white.opacity(0.54)]
        case .shogunMoon:
            [Color.black.opacity(0.12), Color.black.opacity(0.70)]
        case .crimsonTheatre:
            [Color.black.opacity(0.18), Color.black.opacity(0.72)]
        default:
            [Color.black.opacity(0.18), Color.black.opacity(0.66)]
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
        Image(role.artwork(for: game.roleSkin))
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

struct GameLogoMark: View {
    var color = Color(red: 0.96, green: 0.72, blue: 0.28)

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                MafiaMaskShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.96),
                                Color(red: 0.09, green: 0.075, blue: 0.07)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: FillStyle(eoFill: true)
                    )

                MafiaMaskShape()
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.98), color.opacity(0.48)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: max(1, width * 0.025), lineJoin: .round)
                    )

                Path { path in
                    path.move(to: CGPoint(x: width * 0.38, y: height * 0.08))
                    path.addLine(to: CGPoint(x: width * 0.46, y: height * 0.18))
                    path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.05))
                    path.addLine(to: CGPoint(x: width * 0.54, y: height * 0.18))
                    path.addLine(to: CGPoint(x: width * 0.62, y: height * 0.08))
                    path.addLine(to: CGPoint(x: width * 0.58, y: height * 0.27))
                    path.addLine(to: CGPoint(x: width * 0.42, y: height * 0.27))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.72), color],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel("Mafia")
    }
}

private struct MafiaMaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        var path = Path()

        path.move(to: CGPoint(x: width * 0.06, y: height * 0.12))
        path.addLine(to: CGPoint(x: width * 0.46, y: height * 0.34))
        path.addLine(to: CGPoint(x: width * 0.46, y: height * 0.94))
        path.addLine(to: CGPoint(x: width * 0.14, y: height * 0.73))
        path.addLine(to: CGPoint(x: width * 0.10, y: height * 0.46))
        path.closeSubpath()

        path.move(to: CGPoint(x: width * 0.94, y: height * 0.12))
        path.addLine(to: CGPoint(x: width * 0.54, y: height * 0.34))
        path.addLine(to: CGPoint(x: width * 0.54, y: height * 0.94))
        path.addLine(to: CGPoint(x: width * 0.86, y: height * 0.73))
        path.addLine(to: CGPoint(x: width * 0.90, y: height * 0.46))
        path.closeSubpath()

        path.move(to: CGPoint(x: width * 0.17, y: height * 0.49))
        path.addLine(to: CGPoint(x: width * 0.42, y: height * 0.57))
        path.addLine(to: CGPoint(x: width * 0.22, y: height * 0.68))
        path.closeSubpath()

        path.move(to: CGPoint(x: width * 0.83, y: height * 0.49))
        path.addLine(to: CGPoint(x: width * 0.58, y: height * 0.57))
        path.addLine(to: CGPoint(x: width * 0.78, y: height * 0.68))
        path.closeSubpath()

        return path
    }
}

struct CardBackView: View {
    let skin: CardSkin
    let theme: AppTheme
    var cornerRadius: CGFloat = 24

    var body: some View {
        ZStack {
            cardArtwork

            if skin != .premium {
                LinearGradient(
                    colors: [Color.black.opacity(0.02), Color.black.opacity(0.20)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RoundedRectangle(cornerRadius: max(8, cornerRadius - 7), style: .continuous)
                    .stroke(logoColor.opacity(0.62), lineWidth: 0.8)
                    .padding(9)

                GeometryReader { proxy in
                    let side = min(proxy.size.width * logoScale, 76)

                    GameLogoMark(color: logoColor)
                        .frame(width: side, height: side)
                        .position(
                            x: proxy.size.width / 2,
                            y: proxy.size.height * logoVerticalPosition
                        )
                }
            }
        }
        .aspectRatio(3 / 4, contentMode: .fit)
        .clipShape(
            RoundedRectangle(
                cornerRadius: skin == .premium ? 0 : cornerRadius,
                style: .continuous
            )
        )
        .overlay {
            if skin != .premium {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(logoColor.opacity(0.72), lineWidth: 1.1)
            }
        }
    }

    @ViewBuilder
    private var cardArtwork: some View {
        if let artwork = skin.artwork {
            Image(artwork)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.025, blue: 0.10),
                        Color(red: 0.018, green: 0.010, blue: 0.035)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(
                        cornerRadius: max(6, cornerRadius - CGFloat(index * 2)),
                        style: .continuous
                    )
                    .stroke(
                        logoColor.opacity(0.22 - Double(index) * 0.035),
                        lineWidth: 0.7
                    )
                    .padding(CGFloat(15 + index * 9))
                }

                Circle()
                    .fill(Color.black.opacity(0.38))
                    .overlay {
                        Circle().stroke(logoColor.opacity(0.74), lineWidth: 1)
                    }
                    .frame(maxWidth: 112, maxHeight: 112)
            }
        }
    }

    private var logoColor: Color {
        switch skin {
        case .classic:
            Color(red: 1, green: 0.30, blue: 0.58)
        case .premium, .obsidian, .ukiyoE, .evidence:
            Color(red: 0.96, green: 0.72, blue: 0.28)
        case .neonCircuit:
            Color(red: 0.27, green: 0.91, blue: 1)
        }
    }

    private var logoScale: CGFloat {
        switch skin {
        case .classic:
            0.23
        case .premium:
            0
        case .obsidian:
            0.14
        case .neonCircuit:
            0.21
        case .ukiyoE:
            0.26
        case .evidence:
            0.16
        }
    }

    private var logoVerticalPosition: CGFloat {
        switch skin {
        case .classic, .premium, .neonCircuit:
            0.52
        case .obsidian:
            0.55
        case .ukiyoE:
            0.51
        case .evidence:
            0.50
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
