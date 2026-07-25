import AudioToolbox
import Foundation

@MainActor
final class DayCountdown: ObservableObject {
    @Published private(set) var remaining = 180
    @Published private(set) var isRunning = false
    private var timer: Timer?

    var formatted: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    func reset(minutes: Int) {
        reset(seconds: minutes * 60)
    }

    func reset(seconds: Int) {
        stop()
        remaining = max(1, seconds)
    }

    func toggle(tone: EndTone) {
        isRunning ? stop() : start(tone: tone)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func start(tone: EndTone) {
        guard remaining > 0 else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                self.remaining -= 1
                if self.remaining <= 0 {
                    timer.invalidate()
                    self.timer = nil
                    self.isRunning = false
                    AudioServicesPlaySystemSound(tone.soundID)
                }
            }
        }
    }
}
