import SwiftUI

struct ThemePalette {
    let background: Color
    let secondaryBackground: Color
    let surface: Color
    let text: Color
    let secondaryText: Color
    let accent: Color
    let secondaryAccent: Color
    let prefersDark: Bool
}

extension AppTheme {
    var palette: ThemePalette {
        switch self {
        case .neonNoir:
            ThemePalette(
                background: Color(red: 0.025, green: 0.02, blue: 0.07),
                secondaryBackground: Color(red: 0.09, green: 0.025, blue: 0.13),
                surface: Color.white.opacity(0.08),
                text: .white,
                secondaryText: Color.white.opacity(0.68),
                accent: Color(red: 1, green: 0.16, blue: 0.55),
                secondaryAccent: Color(red: 0.1, green: 0.9, blue: 0.94),
                prefersDark: true
            )
        case .artDeco:
            ThemePalette(
                background: Color(red: 0.025, green: 0.09, blue: 0.1),
                secondaryBackground: Color(red: 0.04, green: 0.15, blue: 0.16),
                surface: Color(red: 0.1, green: 0.22, blue: 0.22),
                text: Color(red: 0.98, green: 0.93, blue: 0.78),
                secondaryText: Color(red: 0.77, green: 0.72, blue: 0.58),
                accent: Color(red: 0.88, green: 0.69, blue: 0.3),
                secondaryAccent: Color(red: 0.46, green: 0.8, blue: 0.7),
                prefersDark: true
            )
        case .minimal:
            ThemePalette(
                background: Color(red: 0.96, green: 0.96, blue: 0.94),
                secondaryBackground: .white,
                surface: .white,
                text: Color(red: 0.08, green: 0.08, blue: 0.09),
                secondaryText: Color(red: 0.4, green: 0.4, blue: 0.42),
                accent: Color(red: 0.12, green: 0.12, blue: 0.14),
                secondaryAccent: Color(red: 0.85, green: 0.17, blue: 0.22),
                prefersDark: false
            )
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
            background
            content
        }
        .foregroundStyle(theme.palette.text)
    }

    @ViewBuilder
    private var background: some View {
        switch theme {
        case .neonNoir:
            ZStack {
                LinearGradient(
                    colors: [theme.palette.background, theme.palette.secondaryBackground],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Circle()
                    .fill(theme.palette.accent.opacity(0.2))
                    .frame(width: 300)
                    .blur(radius: 70)
                    .offset(x: 160, y: -260)
                Circle()
                    .fill(theme.palette.secondaryAccent.opacity(0.12))
                    .frame(width: 260)
                    .blur(radius: 80)
                    .offset(x: -170, y: 300)
            }
            .ignoresSafeArea()
        case .artDeco:
            ZStack {
                LinearGradient(
                    colors: [theme.palette.background, theme.palette.secondaryBackground],
                    startPoint: .top, endPoint: .bottom
                )
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(theme.palette.accent.opacity(0.12), lineWidth: 1)
                        .frame(width: CGFloat(90 + index * 70), height: CGFloat(90 + index * 70))
                        .rotationEffect(.degrees(45))
                        .offset(y: -280)
                }
            }
            .ignoresSafeArea()
        case .minimal:
            theme.palette.background.ignoresSafeArea()
        }
    }
}

struct MafiaCard: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(theme.palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme == .artDeco ? 3 : 22))
            .overlay {
                RoundedRectangle(cornerRadius: theme == .artDeco ? 3 : 22)
                    .stroke(theme.palette.accent.opacity(theme == .minimal ? 0.08 : 0.28), lineWidth: 1)
            }
            .shadow(color: theme.palette.accent.opacity(theme == .minimal ? 0.05 : 0.12), radius: 20)
    }
}

extension View {
    func mafiaCard(_ theme: AppTheme) -> some View {
        modifier(MafiaCard(theme: theme))
    }

    func primaryButton(_ theme: AppTheme) -> some View {
        self
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(theme == .minimal ? Color.white : theme.palette.background)
            .background(theme.palette.accent)
            .clipShape(RoundedRectangle(cornerRadius: theme == .artDeco ? 2 : 16))
    }
}
