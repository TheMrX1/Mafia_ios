import SwiftUI

@main
struct MafiaApp: App {
    @StateObject private var game = GameSession()
    @StateObject private var dayTimer = DayCountdown()
    @StateObject private var music = NightMusic()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(game)
                .environmentObject(dayTimer)
                .environmentObject(music)
        }
    }
}
