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
            ThemedBackground(theme: game.theme) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ScreenHeader(
                            "Control room",
                            title: "Настройки",
                            subtitle: "Атмосфера, ритм и звук вашей игры."
                        )

                        themeSection
                        timerSection
                        musicSection
                    }
                    .contentColumn()
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 48)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .fontWeight(.bold)
                        .foregroundStyle(game.theme.palette.accent)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(game.theme.palette.prefersDark ? .dark : .light)
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

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Визуальный стиль")
            ForEach(AppTheme.allCases) { theme in
                Button {
                    withAnimation(.snappy) {
                        game.theme = theme
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(theme.backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 68, height: 58)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(theme.title)
                                .font(.headline)
                            Text(themeDescription(theme))
                                .font(.caption)
                                .foregroundStyle(game.theme.palette.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image(systemName: game.theme == theme ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(game.theme == theme ? game.theme.palette.accent : game.theme.palette.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mafiaCard(game.theme, padding: 12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var timerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel("Дневной таймер")

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Продолжительность")
                        .font(.headline)
                    Text("\(game.dayMinutes) мин.")
                        .font(.title2.bold())
                        .foregroundStyle(game.theme.palette.accent)
                }
                Spacer()
                Stepper("Минуты", value: $game.dayMinutes, in: 1...15)
                    .labelsHidden()
                    .tint(game.theme.palette.accent)
            }

            Divider().overlay(game.theme.palette.border)

            Picker("Сигнал окончания", selection: $game.endTone) {
                ForEach(EndTone.allCases) { tone in
                    Text(tone.title).tag(tone)
                }
            }
            .tint(game.theme.palette.accent)

            Button("Применить и сбросить") {
                dayTimer.reset(minutes: game.dayMinutes)
            }
            .buttonStyle(.bordered)
            .tint(game.theme.palette.accent)
        }
        .mafiaCard(game.theme)
    }

    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("Музыка ночи")

            if let track = music.trackName {
                Label(track, systemImage: "music.note")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
            } else {
                Text("Трек пока не выбран.")
                    .font(.subheadline)
                    .foregroundStyle(game.theme.palette.secondaryText)
            }

            Button(music.trackName == nil ? "Импортировать из Файлов" : "Заменить трек") {
                importerPresented = true
            }
            .buttonStyle(.bordered)
            .tint(game.theme.palette.accent)
        }
        .mafiaCard(game.theme)
    }

    private func themeDescription(_ theme: AppTheme) -> String {
        switch theme {
        case .neonNoir: "Ночной город, стекло и холодный неон"
        case .artDeco: "Изумруд, латунь и атмосфера закрытого клуба"
        case .minimal: "Светлая редакционная эстетика и тишина"
        }
    }
}