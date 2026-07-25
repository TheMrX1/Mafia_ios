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

@MainActor
final class NightMusic: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private static let storedTrackKey = "mafia.music.storedTrack"
    private static let storedTrackNameKey = "mafia.music.storedTrackName"

    @Published private(set) var trackName: String?
    @Published private(set) var isPlaying = false
    @Published var errorMessage: String?
    private var player: AVAudioPlayer?

    override init() {
        super.init()
        restoreTrack()
    }

    func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            guard let source = urls.first else {
                errorMessage = "Файл не был выбран."
                return
            }
            importTrack(from: source)
        case let .failure(error):
            if (error as? CocoaError)?.code != .userCancelled {
                errorMessage = "Не удалось получить выбранный аудиофайл."
            }
        }
    }

    func importTrack(from source: URL) {
        errorMessage = nil
        let accessing = source.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                source.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("NightMusic", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

            let fileExtension = source.pathExtension.isEmpty ? "mp3" : source.pathExtension.lowercased()
            let staging = directory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(fileExtension)
            defer {
                try? FileManager.default.removeItem(at: staging)
            }

            var coordinationError: NSError?
            var copyError: Error?
            NSFileCoordinator().coordinate(
                readingItemAt: source,
                options: [],
                error: &coordinationError
            ) { coordinatedURL in
                do {
                    try FileManager.default.copyItem(at: coordinatedURL, to: staging)
                } catch {
                    copyError = error
                }
            }

            if let coordinationError {
                throw coordinationError
            }
            if let copyError {
                throw copyError
            }

            let probe = try AVAudioPlayer(contentsOf: staging)
            guard probe.prepareToPlay() else {
                throw CocoaError(.fileReadCorruptFile)
            }

            let destination = directory
                .appendingPathComponent("night-track")
                .appendingPathExtension(fileExtension)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            if let previousName = UserDefaults.standard.string(forKey: Self.storedTrackKey) {
                let previous = directory.appendingPathComponent(previousName)
                if previous != destination, FileManager.default.fileExists(atPath: previous.path) {
                    try? FileManager.default.removeItem(at: previous)
                }
            }
            try FileManager.default.moveItem(at: staging, to: destination)

            player = try AVAudioPlayer(contentsOf: destination)
            player?.delegate = self
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            trackName = source.deletingPathExtension().lastPathComponent
            isPlaying = false
            UserDefaults.standard.set(destination.lastPathComponent, forKey: Self.storedTrackKey)
            UserDefaults.standard.set(trackName, forKey: Self.storedTrackNameKey)
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось импортировать этот аудиофайл. Убедитесь, что MP3 полностью загружен в «Файлы»."
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
        Task { @MainActor in self.isPlaying = false }
    }

    private func restoreTrack() {
        guard let storedName = UserDefaults.standard.string(forKey: Self.storedTrackKey) else {
            return
        }

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("NightMusic", isDirectory: true)
            .appendingPathComponent(storedName)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            trackName = UserDefaults.standard.string(forKey: Self.storedTrackNameKey)
                ?? "Сохранённый трек"
        } catch {
            UserDefaults.standard.removeObject(forKey: Self.storedTrackKey)
            UserDefaults.standard.removeObject(forKey: Self.storedTrackNameKey)
            try? FileManager.default.removeItem(at: url)
        }
    }
}
