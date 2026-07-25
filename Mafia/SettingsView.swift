import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var dayTimer: DayCountdown
    @EnvironmentObject private var music: NightMusic
    @State private var importerPresented = false

    var body: some View {
        ThemedBackground(theme: game.theme, wallpaper: game.wallpaper) {
            ZStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ScreenHeader(
                            "Control room",
                            title: "Настройки",
                            subtitle: nil
                        )

                        themeSection
                        wallpaperSection
                        roleSkinSection
                        cardSkinSection
                        timerSection
                        musicSection
                    }
                    .contentColumn()
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 48)
                }

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(game.theme.palette.text)
                        .frame(width: 38, height: 38)
                        .background(game.theme.palette.surface)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(game.theme.palette.border, lineWidth: 0.8)
                        }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 8)
                .padding(.trailing, 18)
            }
        }
        .preferredColorScheme(game.theme.palette.prefersDark ? .dark : .light)
        .presentationBackground(.clear)
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

    private var cardSkinSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Рубашка карты")
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(CardSkin.allCases) { skin in
                    Button {
                        game.cardSkin = skin
                    } label: {
                        VStack(spacing: 10) {
                            CardBackView(skin: skin, theme: game.theme, cornerRadius: 12)
                                .frame(height: 116)
                            Text(skin.title)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                        }
                        .padding(8)
                        .background(
                            game.cardSkin == skin
                                ? game.theme.palette.accent.opacity(0.12)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mafiaCard(game.theme)
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Визуальный стиль")
            ForEach(AppTheme.allCases) { theme in
                Button {
                    game.theme = theme
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(theme.palette.background)
                            .frame(width: 68, height: 58)
                            .overlay {
                                Circle()
                                    .fill(theme.palette.accent)
                                    .frame(width: 22, height: 22)
                            }

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

    private var wallpaperSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Обои")
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(Wallpaper.allCases) { wallpaper in
                    Button {
                        game.wallpaper = wallpaper
                    } label: {
                        ZStack(alignment: .bottomLeading) {
                            Image(wallpaper.artwork)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 128)
                                .clipped()

                            LinearGradient(
                                colors: [.clear, .black.opacity(0.78)],
                                startPoint: .center,
                                endPoint: .bottom
                            )

                            Text(wallpaper.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(10)

                            if game.wallpaper == wallpaper {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .padding(9)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(
                                    game.wallpaper == wallpaper
                                        ? game.theme.palette.accent
                                        : game.theme.palette.border,
                                    lineWidth: game.wallpaper == wallpaper ? 1.5 : 0.8
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var roleSkinSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Образы ролей")
            ForEach(RoleSkin.allCases) { skin in
                Button {
                    game.roleSkin = skin
                } label: {
                    HStack(spacing: 13) {
                        Image(Role.mafia.artwork(for: skin))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(skin.title)
                                .font(.headline)
                            Text(skin.subtitle)
                                .font(.caption)
                                .foregroundStyle(game.theme.palette.secondaryText)
                        }

                        Spacer()

                        Image(systemName: game.roleSkin == skin ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(
                                game.roleSkin == skin
                                    ? game.theme.palette.accent
                                    : game.theme.palette.secondaryText
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mafiaCard(game.theme, padding: 11)
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
