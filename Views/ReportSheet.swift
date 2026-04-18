//
//  ReportSheet.swift
//  Promi
//
//  Sheet de signalement d'un Promi reçu d'un autre utilisateur.
//  3 actions possibles : masquer le Promi, bloquer l'expéditeur,
//  signaler à l'éditeur (email). Les 3 sont indépendantes et
//  cumulables. Le signalement génère un email pré-rempli via mailto.
//

import SwiftUI

struct ReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var contactsStore: ContactsStore

    let promi: PromiItem
    let senderName: String

    @State private var selectedReason: ReportReason = .harassment
    @State private var additionalComment: String = ""
    @State private var didBlock = false
    @State private var didHide = false
    @State private var showBlockConfirmation = false

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color.black.opacity(0.96).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        promoSummaryCard
                        reasonPicker
                        commentField
                        actionButtons
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 64)
                    .padding(.bottom, 32)
                }

                closeButton
                    .padding(.trailing, 20)
                    .padding(.top, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .confirmationDialog(
            isFrench ? "Bloquer \(senderName) ?" : "Block \(senderName)?",
            isPresented: $showBlockConfirmation,
            titleVisibility: .visible
        ) {
            Button(isFrench ? "Bloquer" : "Block", role: .destructive) {
                performBlock()
            }
            Button(isFrench ? "Annuler" : "Cancel", role: .cancel) { }
        } message: {
            Text(isFrench
                 ? "Tous ses Promi actuels et futurs seront masqués. Tu pourras débloquer depuis les Réglages."
                 : "All their current and future Promis will be hidden. You can unblock from Settings.")
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isFrench ? "Signaler" : "Report")
                .font(.system(size: 26, weight: .light))
                .foregroundColor(Brand.orange)
            Text(isFrench
                 ? "Ce Promi a été envoyé par \(senderName)."
                 : "This Promi was sent by \(senderName).")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white.opacity(0.58))
        }
    }

    private var promoSummaryCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(promi.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.white.opacity(0.88))
                .lineLimit(3)
            Text(promi.createdAt, style: .date)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.42))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
        )
    }

    private var reasonPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isFrench ? "MOTIF" : "REASON")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.0)
                .foregroundColor(Color.white.opacity(0.46))
                .padding(.leading, 4)

            ForEach(ReportReason.allCases) { reason in
                Button {
                    Haptics.shared.lightTap()
                    selectedReason = reason
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedReason == reason
                              ? "largecircle.fill.circle"
                              : "circle")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(
                                selectedReason == reason
                                    ? Brand.orange.opacity(0.92)
                                    : Color.white.opacity(0.42)
                            )
                        Text(reason.label(isFrench: isFrench))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.88))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selectedReason == reason
                                  ? Color.white.opacity(0.06)
                                  : Color.white.opacity(0.02))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                selectedReason == reason
                                    ? Brand.orange.opacity(0.38)
                                    : Color.white.opacity(0.08),
                                lineWidth: 0.6
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var commentField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isFrench ? "COMMENTAIRE (OPTIONNEL)" : "COMMENT (OPTIONAL)")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.0)
                .foregroundColor(Color.white.opacity(0.46))
                .padding(.leading, 4)

            TextField(
                isFrench ? "Contexte supplémentaire" : "Additional context",
                text: $additionalComment,
                axis: .vertical
            )
            .lineLimit(3...6)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.white.opacity(0.92))
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
            )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 1. Masquer ce Promi
            actionButton(
                icon: "eye.slash",
                title: isFrench
                    ? (didHide ? "Promi masqué" : "Masquer ce Promi")
                    : (didHide ? "Promi hidden" : "Hide this Promi"),
                subtitle: isFrench
                    ? "Ne plus voir ce Promi dans ta toile"
                    : "Remove this Promi from your canvas",
                accent: Color.white.opacity(0.82),
                done: didHide
            ) {
                Haptics.shared.tinyPop()
                contactsStore.hidePromi(id: promi.id)
                didHide = true
            }

            // 2. Bloquer l'expéditeur
            actionButton(
                icon: "hand.raised.fill",
                title: isFrench
                    ? (didBlock ? "\(senderName) bloqué" : "Bloquer \(senderName)")
                    : (didBlock ? "\(senderName) blocked" : "Block \(senderName)"),
                subtitle: isFrench
                    ? "Masquer tous ses Promi, actuels et futurs"
                    : "Hide all their Promis, current and future",
                accent: Brand.karmaPoor,
                done: didBlock
            ) {
                showBlockConfirmation = true
            }

            // 3. Signaler par email
            actionButton(
                icon: "envelope",
                title: isFrench ? "Signaler à l'éditeur" : "Report to publisher",
                subtitle: isFrench
                    ? "Envoyer un email détaillé à promiapp@gmail.com"
                    : "Send a detailed email to promiapp@gmail.com",
                accent: Brand.orange.opacity(0.92),
                done: false
            ) {
                Haptics.shared.lightTap()
                sendReport()
            }
        }
    }

    @ViewBuilder
    private func actionButton(
        icon: String,
        title: String,
        subtitle: String,
        accent: Color,
        done: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: done ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(done ? Brand.karmaGood : accent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(done ? 0.58 : 0.92))
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.46))
                }
                Spacer()
                if !done {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.32))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(done ? 0.02 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(done ? 0.06 : 0.12), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
        .disabled(done)
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
                Capsule(style: .continuous).fill(Color.white.opacity(0.08))
            )
            .overlay(
                Capsule(style: .continuous).stroke(Color.white.opacity(0.14), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func performBlock() {
        guard let senderId = promi.senderContactId else { return }
        contactsStore.blockContact(id: senderId, reason: selectedReason.rawValue, fallbackName: senderName)
        Haptics.shared.success()
        didBlock = true
    }

    private func sendReport() {
        let subject = isFrench
            ? "Signalement Promi — \(selectedReason.label(isFrench: true))"
            : "Promi Report — \(selectedReason.label(isFrench: false))"

        let body = """
        ---
        Promi ID: \(promi.id.uuidString)
        Title: \(promi.title)
        Sender contact ID: \(promi.senderContactId ?? "unknown")
        Sender Apple ID: \(promi.senderAppleUserId ?? "unknown")
        Reason: \(selectedReason.rawValue)
        Comment: \(additionalComment.isEmpty ? "(none)" : additionalComment)
        Reporter user ID: \(userStore.localUserId)
        Date: \(ISO8601DateFormatter().string(from: Date()))
        ---
        """

        let encoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailto = "mailto:\(LegalConstants.editorEmail)?subject=\(subjectEncoded)&body=\(encoded)"

        if let url = URL(string: mailto) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Report reasons

enum ReportReason: String, CaseIterable, Identifiable {
    case harassment
    case inappropriate
    case spam
    case threat
    case other

    var id: String { rawValue }

    func label(isFrench: Bool) -> String {
        switch self {
        case .harassment:
            return isFrench ? "Harcèlement ou intimidation" : "Harassment or bullying"
        case .inappropriate:
            return isFrench ? "Contenu inapproprié" : "Inappropriate content"
        case .spam:
            return isFrench ? "Spam ou sollicitation non désirée" : "Spam or unwanted solicitation"
        case .threat:
            return isFrench ? "Menace ou incitation à la violence" : "Threat or incitement to violence"
        case .other:
            return isFrench ? "Autre motif" : "Other reason"
        }
    }
}
