import SwiftUI

struct RootView: View {
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var dayTimer: DayCountdown
    @EnvironmentObject private var music: NightMusic
    @State private var settingsPresented = false

    var body: some View {
        NavigationStack {
            ThemedBackground(theme: game.theme) {
                Group {
                    switch game.phase {
                    case .setup:
                        SetupView()
                    case .rules:
                        RulesView()
                    case .reveal:
                        RoleRevealView()
                    case .day:
                        DayView()
                    case .vote:
                        VoteView()
                    case .night:
                        NightView()
                    case .summary:
                        SummaryView()
                    }
                }
                .animation(.snappy, value: game.phase)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .toolbar {
                if game.phase != .reveal {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            settingsPresented = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(game.theme.palette.text)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .background(game.theme.palette.surface)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().stroke(game.theme.palette.border, lineWidth: 1)
                                }
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(game.theme.palette.prefersDark ? .dark : .light)
        .sheet(isPresented: $settingsPresented) {
            SettingsView()
                .environmentObject(game)
                .environmentObject(dayTimer)
                .environmentObject(music)
        }
    }
}