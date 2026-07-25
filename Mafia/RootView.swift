import SwiftUI

struct RootView: View {
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var dayTimer: DayCountdown
    @EnvironmentObject private var music: NightMusic
    @State private var settingsPresented = false

    var body: some View {
        ThemedBackground(theme: game.theme) {
            ZStack {
                Group {
                    switch game.phase {
                    case .setup:
                        SetupView()
                    case .rules:
                        RulesView()
                    case .reveal:
                        RoleRevealView()
                    case .day:
                        HostView()
                    case .vote:
                        HostView()
                    case .night:
                        HostView()
                    case .summary:
                        SummaryView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if game.phase != .reveal {
                    Button {
                        settingsPresented = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(game.theme.palette.text)
                            .frame(width: 38, height: 38)
                            .background(game.theme.palette.surface)
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(game.theme.palette.border, lineWidth: 0.8)
                            }
                            .shadow(color: .black.opacity(0.14), radius: 12, y: 6)
                }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 8)
                    .padding(.trailing, 18)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .preferredColorScheme(game.theme.palette.prefersDark ? .dark : .light)
        .sensoryFeedback(.selection, trigger: game.phase)
        .sheet(isPresented: $settingsPresented) {
            SettingsView()
                .environmentObject(game)
                .environmentObject(dayTimer)
                .environmentObject(music)
        }
    }
}
