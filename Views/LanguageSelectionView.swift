import SwiftUI

// MARK: - LanguageSelectionView
//
// Écran de sélection de langue, présenté dans deux contextes :
//
// 1. ENTRY FLOW (premier lancement) — l'utilisateur n'a jamais choisi de
//    langue (`!userStore.hasChosenLanguage`). Pas de bouton Fermer, le
//    choix est obligatoire pour avancer dans l'app.
//
// 2. SHEET DEPUIS SETTINGS (utilisateur récurrent) — l'utilisateur veut
//    changer sa langue a posteriori. Un bouton Fermer chrome pill est
//    affiché en top-right. Une fois la langue confirmée, la sheet se
//    dismiss automatiquement.
//
// Design chrome cohérent avec toutes les autres pages : PromiChromePageBackground
// (mood-aware) + cards chrome pour les langues + accent orange sur « Promi »
// dans le titre + bouton Continuer orange.

struct LanguageSelectionView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @Environment(\.dismiss) private var dismiss

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @State private var selectedLanguage: String

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

    /// The three supported languages: code + native display name.
    /// Each entry is rendered in its own native script to make the choice
    /// universally recognizable regardless of the current language.
    private let languages: [(code: String, nativeName: String, localizedName: String)] = [
        ("fr", "Français", "French"),
        ("en", "English", "Anglais"),
        ("es", "Español", "Espagnol")
    ]

    init() {
        // Pre-select the currently active language so returning users see
        // their current choice highlighted as the default.
        let current = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "fr"
        _selectedLanguage = State(initialValue: current)
    }

    // MARK: Derived

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    /// True when the view is presented as a sheet from Settings (user has
    /// already gone through the entry flow). Used to conditionally show
    /// the Close button and to decide what happens after choosing.
    private var isSheetMode: Bool {
        userStore.hasChosenLanguage
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 0) {
                Spacer(minLength: 48)

                titleBlock

                Spacer(minLength: 40)

                languageField

                Spacer()

                continueButton
            }

            if isSheetMode {
                closeButton
                    .padding(.trailing, 20)
                    .padding(.top, 16)
            }
        }
    }

    // MARK: Title block

    private var titleBlock: some View {
        VStack(spacing: 12) {
            Text("Promi")
                .font(.system(size: 34, weight: .light))
                .foregroundColor(brandOrange)
                .tracking(0.8)

            Text(subtitleText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white.opacity(0.58))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    /// The subtitle adapts to context:
    /// - Entry flow: stays in a neutral welcoming French (the entry default)
    /// - Sheet mode: uses the user's current language
    private var subtitleText: String {
        if isSheetMode {
            return isEnglish
                ? "change your language."
                : "changez de langue."
        } else {
            return "Choisissez votre langue.\nChoose your language.\nElige tu idioma."
        }
    }

    // MARK: Language field (chrome card with 3 rows)

    private var languageField: some View {
        VStack(spacing: 0) {
            ForEach(Array(languages.enumerated()), id: \.element.code) { index, item in
                languageRow(item: item)

                if index < languages.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 0.6)
                        .padding(.horizontal, 22)
                }
            }
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
            }
        )
        .padding(.horizontal, 22)
    }

    @ViewBuilder
    private func languageRow(item: (code: String, nativeName: String, localizedName: String)) -> some View {
        let isSelected = selectedLanguage == item.code

        Button {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                selectedLanguage = item.code
            }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.nativeName)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(Color.white.opacity(isSelected ? 0.96 : 0.72))

                    Text(item.code.uppercased())
                        .font(.system(size: 10, weight: .regular))
                        .tracking(1.2)
                        .foregroundColor(Color.white.opacity(isSelected ? 0.62 : 0.38))
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(
                            isSelected
                                ? brandOrange.opacity(0.78)
                                : Color.white.opacity(0.26),
                            lineWidth: 1
                        )
                        .frame(width: 18, height: 18)

                    if isSelected {
                        Circle()
                            .fill(brandOrange)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Continue button

    private var continueButton: some View {
        Button(action: continueFlow) {
            Text(continueText)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.96))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(brandOrange.opacity(0.86))
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 0.6)
                    }
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 22)
        .padding(.bottom, 42)
    }

    /// Continue button label adapts to the user's currently pre-selected
    /// language so the choice feels immediate and natural.
    private var continueText: String {
        switch selectedLanguage {
        case "en": return "Continue"
        case "es": return "Continuar"
        default:   return "Continuer"
        }
    }

    // MARK: Close button (sheet mode only)

    private var closeButton: some View {
        Button {
            Haptics.shared.lightTap()
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.86))
                Text(isEnglish ? "Close" : "Fermer")
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

    // MARK: Actions

    private func continueFlow() {
        Haptics.shared.success()
        userStore.chooseLanguage(selectedLanguage)

        // In sheet mode (returning user changing language), dismiss the
        // sheet to return to Settings. In entry flow (first-time user),
        // dismiss is a no-op because the view is part of the root
        // hierarchy — the hasChosenLanguage flag changing triggers the
        // navigation to the next screen (onboarding).
        if isSheetMode {
            dismiss()
        }
    }
}
