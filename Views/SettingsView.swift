import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var contactsStore: ContactsStore

    @AppStorage("promi.visualPack") private var visualPackRawValue: String =
        PromiVisualPack.alveolesSignature.rawValue
    @AppStorage("promi.visualMood") private var visualMoodRawValue: String =
        PromiColorMood.terrePromi.rawValue

     @State private var showLanguagePicker = false
    @State private var showStudio = false
    @State private var showReplayOnboarding = false
    @State private var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "promi.notificationsEnabled")
    @State private var showPaywall = false
    @State private var showLegal = false
    @State private var showUsernameEditor = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showBlockedUsers = false


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

                        sectionLabel(isFrench ? "TOI" : "YOU")
                            .padding(.top, 14)

                        usernameRow
                        appleAccountRow
                        promiPlusRow

                        sectionLabel(isFrench ? "APPLICATION" : "APP")
                            .padding(.top, 14)

                        languageRow
                        studioRow
                        notificationsRow

                        sectionLabel(isFrench ? "DÉCOUVERTE" : "DISCOVER")
                            .padding(.top, 14)

                        replayOnboardingRow

                        sectionLabel(isFrench ? "SÉCURITÉ" : "SAFETY")
                            .padding(.top, 14)

                        blockedUsersRow

                        sectionLabel(isFrench ? "LÉGAL" : "LEGAL")
                            .padding(.top, 14)

                        termsRow
                        privacyRow
                        aboutEditorRow

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
        .sheet(isPresented: $showUsernameEditor) {
            UsernameEditSheet()
                .environmentObject(userStore)
        }
        .sheet(isPresented: $showTerms) {
            LegalDocumentsView(document: .terms)
                .environmentObject(userStore)
        }
        .sheet(isPresented: $showPrivacy) {
            LegalDocumentsView(document: .privacy)
                .environmentObject(userStore)
        }
        .sheet(isPresented: $showPaywall) {
            PromiPlusPaywallView()
                .environmentObject(userStore)
                .environmentObject(promiStore)
        }
        .sheet(isPresented: $showBlockedUsers) {
            BlockedUsersView()
                .environmentObject(userStore)
                .environmentObject(contactsStore)
        }
    }

    // MARK: Header (title + subtitle)

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            // « Réglages » en orange — même accent identité que « Promi »,
            // « Brouillons », « Karma » sur les autres pages.
            Text(isFrench ? "Réglages" : "Settings")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Brand.orange)

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

    private var usernameRow: some View {
        SettingsRow(
            title: isFrench ? "Nom" : "Name",
            value: userStore.username.isEmpty
                ? (isFrench ? "à choisir" : "set name")
                : userStore.username,
            accent: Color.white.opacity(0.82),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            showUsernameEditor = true
        }
    }

    /// Affiche le statut de connexion Apple. Pour l'instant désactivé
    /// (compte Apple Dev requis pour activer la capability "Sign in with
    /// Apple"). Quand `hasCompletedAppleSignIn` est vrai mais sans
    /// `appleUserId`, c'est qu'on a passé le placeholder ; sinon c'est
    /// que l'utilisateur s'est vraiment connecté.
    private var appleAccountRow: some View {
        let isConnected = userStore.appleUserId != nil
        let valueText: String = {
            if isConnected {
                return userStore.appleEmail ?? (isFrench ? "connecté" : "connected")
            }
            return isFrench ? "bientôt" : "coming soon"
        }()
        return SettingsRow(
            title: isFrench ? "Compte Apple" : "Apple account",
            value: valueText,
            accent: isConnected
                ? Brand.orange.opacity(0.92)
                : Color.white.opacity(0.42),
            enabled: false
        ) {}
        .opacity(isConnected ? 1.0 : 0.54)
    }

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

    private var notificationsRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notifications")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.88))
                Text(isFrench ? "rappels veille, jour J, matin" : "eve, day-of, morning reminders")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.52))
            }
            Spacer()
            Toggle("", isOn: $notificationsEnabled)
                .labelsHidden()
                .tint(Brand.orange)
                .onChange(of: notificationsEnabled) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "promi.notificationsEnabled")
                    if newValue {
                        NotificationManager.shared.requestPermission()
                        NotificationManager.shared.rescheduleAll(
                            promis: promiStore.promis,
                            language: userStore.selectedLanguage
                        )
                        NotificationManager.shared.scheduleMorningReminder(
                            promis: promiStore.promis,
                            language: userStore.selectedLanguage
                        )
                    } else {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
            }
        )
    }

    private var replayOnboardingRow: some View {
        SettingsRow(
            title: isFrench ? "Revivre l’onboarding" : "Replay the onboarding",
            value: isFrench ? "tout revoir" : "see it again",
            accent: Brand.orange.opacity(0.92),
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

    private var promiPlusRow: some View {
        SettingsRow(
            title: "Promi Plus",
            value: userStore.isPremium
                ? (isFrench ? "actif" : "active")
                : (isFrench ? "découvrir" : "discover"),
            accent: Brand.orange.opacity(0.92),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            showPaywall = true
        }
    }

    private var blockedUsersRow: some View {
        let count = contactsStore.blockedContacts.count
        return SettingsRow(
            title: isFrench ? "Utilisateurs bloqués" : "Blocked users",
            value: count == 0
                ? (isFrench ? "aucun" : "none")
                : "\(count)",
            accent: count > 0 ? Brand.karmaPoor : Color.white.opacity(0.62),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            showBlockedUsers = true
        }
    }

    private var termsRow: some View {
        SettingsRow(
            title: isFrench ? "Conditions d’utilisation" : "Terms of use",
            value: "v\(LegalConstants.currentTermsVersion)",
            accent: Color.white.opacity(0.62),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            showTerms = true
        }
    }

    private var privacyRow: some View {
        SettingsRow(
            title: isFrench ? "Confidentialité" : "Privacy",
            value: isFrench ? "données locales" : "local data",
            accent: Color.white.opacity(0.62),
            enabled: true
        ) {
            Haptics.shared.lightTap()
            showPrivacy = true
        }
    }

    private var aboutEditorRow: some View {
        SettingsRow(
            title: isFrench ? "Éditeur" : "Publisher",
            value: LegalConstants.editorName,
            accent: Color.white.opacity(0.42),
            enabled: false
        ) {}
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

// MARK: - Username edit sheet
//
// Petit sheet présenté depuis Settings pour modifier le nom d'utilisateur.
// Mêmes codes visuels que UsernameSetupView (chrome pleine page, champ
// centré, bouton Continuer orange) en version compacte.

private struct UsernameEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @State private var typedName: String = ""
    @FocusState private var isFieldFocused: Bool

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    private var canSave: Bool {
        let trimmed = typedName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed != userStore.username
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Fond sombre uni (le sheet est compact, pas la peine du
            // chrome mood-aware complet — on garde simple et lisible).
            Color.black.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 12)

                VStack(spacing: 10) {
                    Text(isFrench ? "Ton nom" : "Your name")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(Color.white.opacity(0.94))

                    Text(isFrench
                         ? "Apparaît dans tes Promi et Nuées partagés."
                         : "Appears in your shared Promis and Nuées.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                TextField(
                    isFrench ? "Prénom ou surnom" : "First name or nickname",
                    text: $typedName
                )
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.white.opacity(0.96))
                .multilineTextAlignment(.center)
                .focused($isFieldFocused)
                .submitLabel(.done)
                .onSubmit { save() }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 0.6)
                )
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    save()
                } label: {
                    Text(isFrench ? "Enregistrer" : "Save")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(
                            canSave
                                ? Color.white.opacity(0.94)
                                : Color.white.opacity(0.38)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    canSave
                                        ? Brand.orange.opacity(0.92)
                                        : Color.white.opacity(0.08)
                                )
                        )
                }
                .disabled(!canSave)
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }

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
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.top, 16)
        }
        .onAppear {
            typedName = userStore.username
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFieldFocused = true
            }
        }
    }

    private func save() {
        guard canSave else { return }
        Haptics.shared.success()
        userStore.setUsername(typedName)
        dismiss()
    }
}
