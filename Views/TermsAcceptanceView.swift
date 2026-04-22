//
//  TermsAcceptanceView.swift
//  Promi
//
//  Écran obligatoire présenté entre la sélection de langue et
//  Sign in with Apple. L'utilisateur DOIT accepter les CGU et la
//  Politique de confidentialité pour continuer — pas d'autre issue.
//
//  Re-présenté automatiquement quand LegalConstants.currentTermsVersion
//  est incrémentée (= modification substantielle des CGU).
//

import SwiftUI

struct TermsAcceptanceView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @State private var hasReadTerms = false
    @State private var showTerms = false
    @State private var showPrivacy = false

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "fr")
    }

    var body: some View {
        ZStack {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 18) {
                    Text(isFrench ? "Avant de commencer" : "Before we begin")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(Color.white.opacity(0.94))
                        .multilineTextAlignment(.center)

                    Text(isFrench
                         ? "Promi est une app sociale. Pour l’utiliser, tu dois lire et accepter les conditions d’utilisation et la politique de confidentialité."
                         : "Promi is a social app. To use it, you must read and accept the terms of use and privacy policy.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.68))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 36)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer().frame(height: 40)

                VStack(spacing: 12) {
                    Button {
                        Haptics.shared.lightTap()
                        showTerms = true
                    } label: {
                        documentRow(
                            icon: "doc.text",
                            title: isFrench ? "Conditions d’utilisation" : "Terms of use"
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        Haptics.shared.lightTap()
                        showPrivacy = true
                    } label: {
                        documentRow(
                            icon: "lock.shield",
                            title: isFrench ? "Politique de confidentialité" : "Privacy policy"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 16) {
                    Toggle(isOn: $hasReadTerms) {
                        Text(isFrench
                             ? "J’ai lu et j’accepte les deux documents."
                             : "I have read and accept both documents.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.78))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Brand.orange))
                    .padding(.horizontal, 32)

                    Button {
                        accept()
                    } label: {
                        Text(isFrench ? "Continuer" : "Continue")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(
                                hasReadTerms
                                    ? Color.white.opacity(0.94)
                                    : Color.white.opacity(0.38)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        hasReadTerms
                                            ? Brand.orange.opacity(0.92)
                                            : Color.white.opacity(0.08)
                                    )
                            )
                    }
                    .disabled(!hasReadTerms)
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 36)
            }
        }
        .sheet(isPresented: $showTerms) {
            LegalDocumentsView(document: .terms)
                .environmentObject(userStore)
        }
        .sheet(isPresented: $showPrivacy) {
            LegalDocumentsView(document: .privacy)
                .environmentObject(userStore)
        }
    }

    private func documentRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white.opacity(0.72))

            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.white.opacity(0.92))

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.46))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        )
    }

    private func accept() {
        guard hasReadTerms else { return }
        Haptics.shared.success()
        userStore.acceptCurrentTerms()
    }
}
