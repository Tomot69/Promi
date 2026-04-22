//
//  LegalDocumentsView.swift
//  Promi
//
//  Sheet réutilisable qui affiche les Conditions d’utilisation OU la
//  Politique de confidentialité, selon le paramètre `document`.
//
//  Le texte est embarqué localement (consultable hors-ligne) avec un
//  bouton optionnel "Voir en ligne" qui ouvre la version GitHub Pages
//  équivalente. Les deux versions doivent rester strictement identiques.
//

import SwiftUI

struct LegalDocumentsView: View {
    enum Document {
        case terms
        case privacy
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore

    let document: Document

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "fr")
    }

    private var title: String {
        switch document {
        case .terms:   return isFrench ? "Conditions d’utilisation" : "Terms of use"
        case .privacy: return isFrench ? "Politique de confidentialité" : "Privacy policy"
        }
    }

    private var bodyText: String {
        switch document {
        case .terms:
            return isFrench ? LegalTexts.termsFR : LegalTexts.termsEN
        case .privacy:
            return isFrench ? LegalTexts.privacyFR : LegalTexts.privacyEN
        }
    }

    private var onlineURL: URL {
        switch document {
        case .terms:   return LegalConstants.termsURL
        case .privacy: return LegalConstants.privacyURL
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color.black.opacity(0.96).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(title)
                            .font(.system(size: 26, weight: .light))
                            .foregroundColor(Brand.orange)
                            .padding(.top, 8)

                        Text(isFrench
                             ? "Version \(LegalConstants.currentTermsVersion) — dernière mise à jour avril 2026"
                             : "Version \(LegalConstants.currentTermsVersion) — last updated April 2026")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.42))

                        Text(bodyText)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.86))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 12)

                        Link(destination: onlineURL) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 12, weight: .medium))
                                Text(isFrench ? "Voir en ligne" : "View online")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(Brand.orange.opacity(0.92))
                        }
                        .padding(.top, 16)

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 32)
                }

                closeButton
                    .padding(.trailing, 20)
                    .padding(.top, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

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
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
    }
}
