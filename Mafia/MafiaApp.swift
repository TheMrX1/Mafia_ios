import SwiftUI

@main
struct MafiaApp: App {
    @StateObject private var game = GameSession()
    @StateObject private var dayTimer = DayCountdown()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(game)
                .environmentObject(dayTimer)
        }
    }
}
