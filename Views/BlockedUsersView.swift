//
//  BlockedUsersView.swift
//  Promi
//
//  Liste des contacts bloqués, accessible depuis Settings → Sécurité.
//  Permet de débloquer chaque contact individuellement (réversible :
//  les Promi redeviennent visibles dans la toile).
//

import SwiftUI

struct BlockedUsersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var contactsStore: ContactsStore

    @State private var unblockTargetId: String?
    @State private var showUnblockConfirmation = false

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "fr")
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.96).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                header
                    .padding(.top, 64)
                    .padding(.horizontal, 22)

                if contactsStore.blockedContacts.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(contactsStore.blockedContacts) { contact in
                                blockedContactRow(contact)
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 40)
                    }
                }

                Spacer()
            }

            closeButton
                .padding(.trailing, 20)
                .padding(.top, 16)
        }
        .confirmationDialog(
            isFrench ? "Débloquer ?" : "Unblock?",
            isPresented: $showUnblockConfirmation,
            titleVisibility: .visible
        ) {
            Button(isFrench ? "Débloquer" : "Unblock") {
                if let id = unblockTargetId {
                    Haptics.shared.tinyPop()
                    contactsStore.unblockContact(id: id)
                }
            }
            Button(isFrench ? "Annuler" : "Cancel", role: .cancel) { }
        } message: {
            Text(isFrench
                 ? "Ses Promi redeviendront visibles dans ta toile."
                 : "Their Promis will become visible in your canvas again.")
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isFrench ? "Utilisateurs bloqués" : "Blocked users")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(Color.white.opacity(0.94))
            Text(isFrench
                 ? "Les Promi de ces personnes sont masqués."
                 : "Promis from these people are hidden.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(Color.white.opacity(0.28))
            Text(isFrench ? "Personne n'est bloqué." : "No one is blocked.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    @ViewBuilder
    private func blockedContactRow(_ contact: PromiContact) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Brand.karmaPoor.opacity(0.72))
                    .frame(width: 36, height: 36)
                Text(initialOf(contact.displayName))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.92))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.displayName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.88))

                if let reason = contact.blockReason, !reason.isEmpty {
                    Text(reason)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.42))
                        .lineLimit(1)
                }

                if let date = contact.blockedAt {
                    Text(date, style: .date)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.32))
                }
            }

            Spacer()

            Button {
                Haptics.shared.lightTap()
                unblockTargetId = contact.id
                showUnblockConfirmation = true
            } label: {
                Text(isFrench ? "Débloquer" : "Unblock")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Brand.orange.opacity(0.92))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule().fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        Capsule().stroke(Brand.orange.opacity(0.32), lineWidth: 0.6)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
        )
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

    private func initialOf(_ name: String) -> String {
        guard let c = name.trimmingCharacters(in: .whitespaces).first else { return "?" }
        return String(c).uppercased()
    }
}
