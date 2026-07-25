import AVFoundation
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
        stop()
        remaining = minutes * 60
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
                remaining -= 1
                if remaining <= 0 {
                    timer.invalidate()
                    self.timer = nil
                    self.isRunning = false
                    AudioServicesPlaySystemSound(tone.soundID)
                }
            }
        }
    }
}

@MainActor
final class NightMusic: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var trackName: String?
    @Published private(set) var isPlaying = false
    @Published var errorMessage: String?
    private var player: AVAudioPlayer?

    func importTrack(from source: URL) {
        do {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("NightMusic", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let destination = directory.appendingPathComponent(source.lastPathComponent)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            let accessing = source.startAccessingSecurityScopedResource()
            defer {
                if accessing { source.stopAccessingSecurityScopedResource() }
            }
            try FileManager.default.copyItem(at: source, to: destination)
            player = try AVAudioPlayer(contentsOf: destination)
            player?.delegate = self
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            trackName = source.deletingPathExtension().lastPathComponent
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось открыть аудиофайл."
        }
    }

    func toggle() {
        guard let player else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            if player.isPlaying {
                player.pause()
                isPlaying = false
            } else {
                player.play()
                isPlaying = true
            }
        } catch {
            errorMessage = "Не удалось запустить воспроизведение."
        }
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        isPlaying = false
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in isPlaying = false }
    }
}
