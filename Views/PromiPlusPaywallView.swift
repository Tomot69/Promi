//
//  PromiPlusPaywallView.swift
//  Promi
//
//  Paywall Promi Plus. Affiché quand l'utilisateur atteint la limite
//  du free tier (5 Promi/jour OU 2 Nuées totales), ou accessible
//  manuellement depuis le menu + ou depuis Settings.
//
//  UI prête à brancher sur StoreKit 2 le jour d'Apple Dev payé.
//  Le bouton d'achat est un placeholder visuel pour l'instant.
//

import SwiftUI

struct PromiPlusPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @EnvironmentObject var promiStore: PromiStore

    @State private var selectedPlan: PlusPlan = .yearly

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    enum PlusPlan: String, CaseIterable {
        case monthly
        case yearly
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection
                    benefitsSection
                    planSelector
                    subscribeButton
                    restoreButton
                    legalFooter
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 68)
                .padding(.bottom, 32)
            }

            closeButton
                .padding(.trailing, 20)
                .padding(.top, 16)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            // Logo composition (même style que les slides onboarding)
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Brand.orange.opacity(0.88))
                    .frame(width: 68, height: 82)
                    .offset(x: -14, y: -4)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 58, height: 68)
                    .offset(x: 18, y: 12)
                Circle()
                    .fill(Color.black.opacity(0.88))
                    .frame(width: 42, height: 42)
            }
            .padding(.bottom, 8)

            HStack(spacing: 0) {
                Text("Promi")
                    .foregroundColor(Brand.orange)
                Text(" Plus")
                    .foregroundColor(Color.white.opacity(0.94))
            }
            .font(.system(size: 30, weight: .light))

            Text(isFrench
                 ? "Promi sans limites. Tes promesses, tes cercles, ton rythme."
                 : "Promi without limits. Your promises, your circles, your pace.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white.opacity(0.64))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(spacing: 10) {
            benefitRow(
                icon: "infinity",
                title: isFrench ? "Promi illimités" : "Unlimited Promis",
                subtitle: isFrench
                    ? "Plus de limite quotidienne"
                    : "No daily limit"
            )
            benefitRow(
                icon: "circle.hexagongrid.fill",
                title: isFrench ? "Nuées illimitées" : "Unlimited Nuées",
                subtitle: isFrench
                    ? "Autant de cercles que tu veux"
                    : "As many circles as you want"
            )
            benefitRow(
                icon: "hands.sparkles.fill",
                title: isFrench ? "Social complet" : "Full social",
                subtitle: isFrench
                    ? "Envoi, réception, invitations"
                    : "Send, receive, invitations"
            )
            benefitRow(
                icon: "paintpalette.fill",
                title: isFrench ? "7 packs × 3 moods" : "7 packs × 3 moods",
                subtitle: isFrench
                    ? "21 combinaisons visuelles"
                    : "21 visual combinations"
            )
        }
    }

    @ViewBuilder
    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Brand.orange.opacity(0.86))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.92))
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
        )
    }

    // MARK: - Plan selector

    private var planSelector: some View {
        HStack(spacing: 10) {
            planCard(
                plan: .monthly,
                title: isFrench ? "Mensuel" : "Monthly",
                price: QuotaConstants.monthlyPriceDisplay,
                subtitle: isFrench ? "par mois" : "per month"
            )
            planCard(
                plan: .yearly,
                title: isFrench ? "Annuel" : "Yearly",
                price: QuotaConstants.yearlyPriceDisplay,
                subtitle: isFrench
                    ? "par an · \(QuotaConstants.yearlySavingsDisplay) d'économie"
                    : "per year · save \(QuotaConstants.yearlySavingsDisplay)"
            )
        }
    }

    @ViewBuilder
    private func planCard(plan: PlusPlan, title: String, price: String, subtitle: String) -> some View {
        let isSelected = selectedPlan == plan

        Button {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                selectedPlan = plan
            }
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.94 : 0.62))
                Text(price)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(isSelected ? Brand.orange : Color.white.opacity(0.72))
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.58 : 0.38))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.08 : 0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isSelected ? Brand.orange.opacity(0.62) : Color.white.opacity(0.10),
                        lineWidth: isSelected ? 1.0 : 0.6
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subscribe button (placeholder until StoreKit)

    private var subscribeButton: some View {
        VStack(spacing: 10) {
            // Placeholder — sera remplacé par un vrai appel StoreKit 2
            // Product.purchase() quand Apple Dev sera payé et les produits
            // configurés dans App Store Connect.
            Button {
                Haptics.shared.lightTap()
                // TODO: StoreKit 2 purchase flow
            } label: {
                Text(isFrench ? "S'abonner" : "Subscribe")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.38))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                    )
            }
            .buttonStyle(.plain)
            .disabled(true) // Désactivé tant que StoreKit pas branché.

            Text(isFrench
                 ? "Abonnement disponible bientôt."
                 : "Subscription available soon.")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.38))
        }
    }

    // MARK: - Restore button

    private var restoreButton: some View {
        Button {
            // TODO: StoreKit 2 restore purchases
            Haptics.shared.lightTap()
        } label: {
            Text(isFrench ? "Restaurer mes achats" : "Restore purchases")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))
                .underline(color: Color.white.opacity(0.24))
        }
        .buttonStyle(.plain)
        .disabled(true)
    }

    // MARK: - Legal footer

    private var legalFooter: some View {
        VStack(spacing: 4) {
            Text(isFrench
                 ? "L'abonnement se renouvelle automatiquement. Annulable à tout moment via les réglages de ton compte Apple."
                 : "Subscription auto-renews. Cancel anytime from your Apple account settings.")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(Color.white.opacity(0.32))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 12)

            HStack(spacing: 12) {
                Link(isFrench ? "Conditions" : "Terms", destination: LegalConstants.termsURL)
                Link(isFrench ? "Confidentialité" : "Privacy", destination: LegalConstants.privacyURL)
            }
            .font(.system(size: 10, weight: .regular))
            .foregroundColor(Color.white.opacity(0.42))
        }
    }

    // MARK: - Close

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
                Capsule(style: .continuous).fill(Color.white.opacity(0.08))
            )
            .overlay(
                Capsule(style: .continuous).stroke(Color.white.opacity(0.14), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
    }
}
