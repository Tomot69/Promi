//
//  UsernameSetupView.swift
//  Promi
//
//  Dernier écran de l'entry flow : choix du nom d'utilisateur qui sera
//  visible pour les autres quand ils reçoivent un Promi ou rejoignent
//  une Nuée. Présenté après l'onboarding, avant le tuto.
//
//  Si l'utilisateur a signé avec Apple, son nom Apple est pré-rempli en
//  suggestion. Il peut toujours le modifier.
//

import SwiftUI

struct UsernameSetupView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @State private var typedName: String = ""
    @FocusState private var isFieldFocused: Bool

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    private var canValidate: Bool {
        !typedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 12) {
                    Text(isEnglish ? "Who are you on Promi?" : "Qui es-tu sur Promi ?")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(Color.white.opacity(0.94))
                        .multilineTextAlignment(.center)

                    Text(isEnglish
                         ? "This name appears when you send a Promi or join a Nuée. You can change it anytime in Settings."
                         : "Ce nom apparaît quand tu envoies un Promi ou rejoins une Nuée. Tu peux le changer à tout moment dans les réglages.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.64))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 36)
                        .fixedSize(horizontal: false, vertical: true)
                }

                TextField(
                    isEnglish ? "First name or nickname" : "Prénom ou surnom",
                    text: $typedName
                )
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color.white.opacity(0.96))
                .multilineTextAlignment(.center)
                .focused($isFieldFocused)
                .submitLabel(.done)
                .onSubmit { validate() }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
                )
                .padding(.horizontal, 36)

                Spacer()

                Button {
                    validate()
                } label: {
                    Text(isEnglish ? "Continue" : "Continuer")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(
                            canValidate
                                ? Color.white.opacity(0.94)
                                : Color.white.opacity(0.38)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    canValidate
                                        ? Brand.orange.opacity(0.92)
                                        : Color.white.opacity(0.08)
                                )
                        )
                }
                .disabled(!canValidate)
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
        .onAppear {
            // Pré-remplir avec le nom Apple si dispo, sinon rien.
            if typedName.isEmpty {
                typedName = userStore.appleFullName ?? ""
            }
            // Ouvrir le clavier automatiquement au bout de 400ms pour
            // laisser le temps à la transition de se terminer proprement.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isFieldFocused = true
            }
        }
    }

    private func validate() {
        guard canValidate else { return }
        Haptics.shared.success()
        userStore.setUsername(typedName)
    }
}
