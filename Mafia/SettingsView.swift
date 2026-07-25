import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var dayTimer: DayCountdown
    @EnvironmentObject private var music: NightMusic
    @State private var importerPresented = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Тема") {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            game.theme = theme
                        } label: {
                            HStack {
                                Circle()
                                    .fill(theme.palette.accent)
                                    .frame(width: 18, height: 18)
                                Text(theme.title)
                                Spacer()
                                if game.theme == theme {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section("Дневной таймер") {
                    Stepper("\(game.dayMinutes) мин.", value: $game.dayMinutes, in: 1...15)
                    Picker("Рингтон", selection: $game.endTone) {
                        ForEach(EndTone.allCases) { tone in
                            Text(tone.title).tag(tone)
                        }
                    }
                    Button("Применить и сбросить таймер") {
                        dayTimer.reset(minutes: game.dayMinutes)
                    }
                }

                Section("Музыка ночи") {
                    if let track = music.trackName {
                        Label(track, systemImage: "music.note")
                    }
                    Button(music.trackName == nil ? "Импортировать из Файлов" : "Заменить трек") {
                        importerPresented = true
                    }
                }
            }
            .navigationTitle("Настройки")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .fileImporter(
            isPresented: $importerPresented,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                music.importTrack(from: url)
            }
        }
    }
}
