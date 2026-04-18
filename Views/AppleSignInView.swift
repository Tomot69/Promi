//
//  AppleSignInView.swift
//  Promi
//
//  Écran Sign in with Apple présenté entre la sélection de langue et
//  l'onboarding. Permet d'attacher l'identité Apple au compte local
//  (indispensable pour la synchronisation sociale future via CloudKit)
//  OU de continuer sans compte (mode local-only, comme avant).
//

import SwiftUI
// import AuthenticationServices — décommenter quand compte Apple Dev
// payé + capability "Sign in with Apple" activée.

struct AppleSignInView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    // signInError retiré — réinsérer quand le bouton Apple sera réactivé.

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    var body: some View {
        ZStack {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 36) {
                Spacer()

                // Logo card (même langage que SplashScreenView)
                logoCard

                // Title + subtitle
                VStack(spacing: 10) {
                    Text(isEnglish ? "Welcome to " : "Bienvenue sur ")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(Color.white.opacity(0.94))
                    + Text("Promi")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(Brand.orange)

                    Text(isEnglish
                         ? "Connect to share Promis and join Nuées with the people around you."
                         : "Connectez-vous pour partager des Promi et rejoindre des Nuées avec vos proches.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.68))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Sign in with Apple button (temporairement désactivé —
                // nécessite un compte Apple Developer payé pour activer
                // la capability "Sign in with Apple". Tout le code est
                // en place ; il suffira d'activer la capability dans
                // Signing & Capabilities et de décommenter le bouton
                // réel quand le compte dev sera payé.)
                VStack(spacing: 14) {
                    // Placeholder visuel du futur bouton Apple.
                    HStack(spacing: 10) {
                        Image(systemName: "applelogo")
                            .font(.system(size: 18, weight: .medium))
                        Text(isEnglish ? "Sign in with Apple" : "Se connecter avec Apple")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(Color.white.opacity(0.38))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                    )
                    .padding(.horizontal, 32)

                    Text(isEnglish
                         ? "Social sync arrives soon."
                         : "La synchronisation sociale arrive bientôt.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.42))
                        .multilineTextAlignment(.center)

                    Button {
                        Haptics.shared.lightTap()
                        userStore.skipAppleSignIn()
                    } label: {
                        Text(isEnglish ? "Continue" : "Continuer")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.94))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Brand.orange.opacity(0.92))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: Logo card (identique à SplashScreenView)

    private var logoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(width: 132, height: 168)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 0.6)
                .frame(width: 132, height: 168)

            Image("LogoPromi")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 110)
        }
    }

    // MARK: Sign in handler — REACTIVER QUAND APPLE DEV PAYÉ
    //
    // La fonction `handleAppleSignIn(_:)` complète (gestion du Result
    // ASAuthorization, extraction du user id / fullName / email) est
    // préservée dans l'historique Git. Elle sera réinsérée ici quand
    // la capability "Sign in with Apple" sera activée dans le projet.
    // UserStore.saveAppleSignIn() existe déjà et attend juste les
    // données — rien d'autre à changer côté modèle.
}
