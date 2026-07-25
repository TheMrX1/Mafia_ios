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
            }
            .toolbar {
                if game.phase != .reveal {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            settingsPresented = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(game.theme.palette.text)
                        }
                    }
                }
            }
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
