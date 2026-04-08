//
//  DraftsView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - DraftsView
//
// Vue brouillons accessible depuis le dropdown du bouton "+". Design chrome
// cohérent avec les dropdown menus (tri, +) et la page Mes/Mon Promi :
// mood home background + ultraThinMaterial + dark tint. Le mot "Brouillon"
// dans le titre est coloré en orange comme accent de marque.

struct DraftsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var draftStore: DraftStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PromiChromePageBackground(
                    pack: currentPack,
                    mood: currentMood,
                    promis: promiStore.promis,
                    languageCode: userStore.selectedLanguage
                )

                VStack(spacing: 0) {
                    topHeader

                    if draftStore.drafts.isEmpty {
                        emptyState
                    } else {
                        draftList
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var topHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                titleAttributed
                    .font(.system(size: 32, weight: .light))

                Text("les promesses que vous n’avez pas encore validées")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
                    .tracking(0.2)
            }

            Spacer()

            closeButton
                .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }

    private var useSingular: Bool {
        draftStore.drafts.count == 1
    }

    /// "Mon " (or "Mes ") in near-white + "Brouillon(s)" in the brand orange,
    /// built as an AttributedString (iOS 26+ idiom, replaces Text + concat).
    private var titleAttributed: Text {
        let prefix = useSingular ? "Mon " : "Mes "
        let suffix = useSingular ? "Brouillon" : "Brouillons"
        var attributed = AttributedString(prefix + suffix)
        attributed.foregroundColor = Color.white.opacity(0.94)
        if let range = attributed.range(of: suffix) {
            attributed[range].foregroundColor = Color(red: 0.98, green: 0.56, blue: 0.22)
        }
        return Text(attributed)
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(action: {
            Haptics.shared.lightTap()
            dismiss()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.82))

                Text("Fermer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.94))
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
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

    // MARK: - Draft list

    @ViewBuilder
    private var draftList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(draftStore.drafts) { draft in
                    DraftChromeCard(
                        draft: draft,
                        languageCode: userStore.selectedLanguage
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 28)
        }
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyState: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 76, height: 76)

                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                        .frame(width: 76, height: 76)

                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(Color.white.opacity(0.68))
                }

                Text("Aucun brouillon")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(Color.white.opacity(0.88))

                Text("Les promesses commencées sans validation sont conservées ici pour plus tard.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Draft chrome card

private struct DraftChromeCard: View {
    @EnvironmentObject var userStore: UserStore
    let draft: PromiDraft
    let languageCode: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.30))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.90))
                    .lineLimit(2)

                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
            }

            Spacer(minLength: 0)

            Image(systemName: "pencil.tip")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Color.white.opacity(0.50))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
            }
        )
    }

    private var title: String {
        let trimmed = draft.title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty ? "Brouillon sans titre" : trimmed
    }

    private var subtitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageCode.isEmpty ? "fr_FR" : languageCode)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Créé le \(formatter.string(from: draft.createdAt))"
    }
}
