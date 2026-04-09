import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @AppStorage("promi.visualPack") private var visualPackRawValue: String =
        PromiVisualPack.alveolesSignature.rawValue
    @AppStorage("promi.visualMood") private var visualMoodRawValue: String =
        PromiColorMood.terrePromi.rawValue

    @State private var showLanguagePicker = false
    @State private var showStudio = false
    @State private var showReplayOnboarding = false

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // Chrome identique au CompactMenuSurface — mood-aware, même
                // recette que les dropdown menus tri/+ du home.
                PromiChromePageBackground(
                    pack: currentPack,
                    mood: currentMood,
                    promis: promiStore.promis,
                    languageCode: userStore.selectedLanguage
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                            .padding(.top, 8)

                        sectionLabel(isFrench ? "APPLICATION" : "APP")
                            .padding(.top, 14)

                        languageRow
                        studioRow

                        sectionLabel(isFrench ? "DÉCOUVERTE" : "DISCOVER")
                            .padding(.top, 14)

                        replayOnboardingRow

                        sectionLabel(isFrench ? "BIENTÔT" : "COMING SOON")
                            .padding(.top, 14)

                        comingSoonRow(
                            title: isFrench ? "Notifications" : "Notifications",
                            caption: isFrench ? "rappels intelligents" : "smart reminders"
                        )
                        comingSoonRow(
                            title: "Promi Premium",
                            caption: isFrench ? "partage, groupes, karma avancé" : "sharing, groups, advanced karma"
                        )

                        footer
                            .padding(.top, 24)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 70)      // space for the floating close button
                    .padding(.bottom, 40)
                }

                closeButton
                    .padding(.trailing, 20)
                    .padding(.top, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguageSelectionView()
        }
        .sheet(isPresented: $showStudio) {
            PaletteView()
        }
        .fullScreenCover(isPresented: $showReplayOnboarding) {
            OnboardingView()
        }
    }

    // MARK: Header (title + subtitle)

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            // « Réglages » en orange — même accent identité que « Promi »,
            // « Brouillons », « Karma » sur les autres pages.
            Text(isFrench ? "Réglages" : "Settings")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(brandOrange)

            Text(isFrench
                 ? "préférences, visuels, découverte"
                 : "preferences, visuals, discovery")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Section label

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.0)
            .foregroundColor(Color.white.opacity(0.46))
            .padding(.leading, 4)
    }

    // MARK: Rows

    private var languageRow: some View {
        SettingsRow(
            title: isFrench ? "Langue" : "Language",
            value: userStore.selectedLanguage.uppercased(),
            accent: Color.white.opacity(0.82),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            showLanguagePicker = true
        }
    }

    private var studioRow: some View {
        SettingsRow(
            title: isFrench ? "Le Studio" : "The Studio",
            value: isFrench ? "visuels & moods" : "visuals & moods",
            accent: Color.white.opacity(0.82),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            showStudio = true
        }
    }

    private var replayOnboardingRow: some View {
        SettingsRow(
            title: isFrench ? "Revivre l’onboarding" : "Replay the onboarding",
            value: isFrench ? "tout revoir" : "see it again",
            accent: brandOrange.opacity(0.92),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            // Reset the flag so the app knows the user has not completed
            // onboarding anymore, then present OnboardingView as a full-screen
            // cover. When the user finishes (or skips to the end), the
            // OnboardingView calls completeOnboarding + dismiss(), which pops
            // this cover and brings them back to Settings.
            userStore.replayOnboarding()
            showReplayOnboarding = true
        }
    }

    private func comingSoonRow(title: String, caption: String) -> some View {
        SettingsRow(
            title: title,
            value: caption,
            accent: Color.white.opacity(0.42),
            enabled: false
        ) {}
        .opacity(0.54)
    }

    // MARK: Footer

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isFrench
                 ? "Vos Promi restent sur votre appareil."
                 : "Your Promis stay on your device.")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.42))

            Text(isFrench
                 ? "Pas de compte, pas de serveur, pas de publicité."
                 : "No account, no server, no ads.")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.34))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    // MARK: Close button (chrome pill)

    private var closeButton: some View {
        Button {
            Haptics.shared.lightTap()
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.86))
                Text(isFrench ? "Fermer" : "Close")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.92))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                ZStack {
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                    Capsule(style: .continuous)
                        .fill(Color.black.opacity(0.22))
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                }
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings row (chrome card)

private struct SettingsRow: View {
    let title: String
    let value: String
    let accent: Color
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.88))

                Spacer(minLength: 12)

                Text(value)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(accent)
                    .lineLimit(1)

                if enabled {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.42))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}
