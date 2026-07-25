import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: GameSession
    @EnvironmentObject private var music: NightMusic
    @State private var importerPresented = false

    private let twoColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    private let threeColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ThemedBackground(theme: game.theme, wallpaper: game.wallpaper) {
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 22) {
                        ScreenHeader(
                            "Control room",
                            title: "Настройки",
                            subtitle: nil
                        )

                        wallpaperSection
                        roleSkinSection
                        cardSkinSection
                        musicSection
                    }
                    .contentColumn()
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(game.theme.palette.text)
                        .frame(width: 44, height: 44)
                        .background(game.theme.palette.elevatedSurface)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(game.theme.palette.border, lineWidth: 1)
                        }
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                .padding(.trailing, 18)
            }
        }
        .preferredColorScheme(.dark)
        .presentationBackground(.clear)
        .fileImporter(
            isPresented: $importerPresented,
            allowedContentTypes: [.mp3, .audio],
            allowsMultipleSelection: false
        ) { result in
            music.handleImportResult(result)
        }
    }

    private var wallpaperSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Обои")

            LazyVGrid(columns: twoColumns, spacing: 10) {
                ForEach(Wallpaper.allCases) { wallpaper in
                    Button {
                        game.wallpaper = wallpaper
                    } label: {
                        ZStack(alignment: .bottomLeading) {
                            Image(wallpaper.artwork)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 128)
                                .clipped()

                            LinearGradient(
                                colors: [.clear, .black.opacity(0.84)],
                                startPoint: .center,
                                endPoint: .bottom
                            )

                            Text(wallpaper.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .padding(10)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .selectionOutline(
                            selected: game.wallpaper == wallpaper,
                            cornerRadius: 15,
                            idleColor: game.theme.palette.border
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(SettingsTileButtonStyle())
                    .accessibilityLabel(wallpaper.title)
                    .accessibilityAddTraits(game.wallpaper == wallpaper ? .isSelected : [])
                }
            }
        }
    }

    private var roleSkinSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Образы ролей")

            LazyVGrid(columns: threeColumns, spacing: 8) {
                ForEach(RoleSkin.allCases) { skin in
                    Button {
                        game.roleSkin = skin
                    } label: {
                        VStack(spacing: 8) {
                            Image(Role.mafia.artwork(for: skin))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 92)
                                .clipped()
                                .overlay(alignment: .bottom) {
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.54)],
                                        startPoint: .center,
                                        endPoint: .bottom
                                    )
                                }

                            Text(skin.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(game.theme.palette.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)
                                .padding(.horizontal, 5)
                                .padding(.bottom, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .background(game.theme.palette.elevatedSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .selectionOutline(
                            selected: game.roleSkin == skin,
                            cornerRadius: 14,
                            idleColor: game.theme.palette.border
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(SettingsTileButtonStyle())
                    .accessibilityLabel(skin.title)
                    .accessibilityAddTraits(game.roleSkin == skin ? .isSelected : [])
                }
            }
        }
    }

    private var cardSkinSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Рубашка карты")

            LazyVGrid(columns: twoColumns, spacing: 10) {
                ForEach(CardSkin.allCases) { skin in
                    Button {
                        game.cardSkin = skin
                    } label: {
                        VStack(spacing: 9) {
                            CardBackView(skin: skin, theme: game.theme, cornerRadius: 13)
                                .frame(maxWidth: .infinity)
                                .frame(height: 154)

                            Text(skin.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(game.theme.palette.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                                .padding(.horizontal, 6)
                                .padding(.bottom, 8)
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .background(game.theme.palette.elevatedSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .selectionOutline(
                            selected: game.cardSkin == skin,
                            cornerRadius: 16,
                            idleColor: game.theme.palette.border
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(SettingsTileButtonStyle())
                    .accessibilityLabel(skin.title)
                    .accessibilityAddTraits(game.cardSkin == skin ? .isSelected : [])
                }
            }
        }
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

            if let error = music.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .mafiaCard(game.theme)
    }
}

private struct SettingsTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private extension View {
    func selectionOutline(
        selected: Bool,
        cornerRadius: CGFloat,
        idleColor: Color
    ) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    selected
                        ? Color(red: 1, green: 0.39, blue: 0.035)
                        : idleColor,
                    lineWidth: selected ? 3 : 0.8
                )
                .padding(selected ? 1.5 : 0)
                .allowsHitTesting(false)
        }
    }
}
