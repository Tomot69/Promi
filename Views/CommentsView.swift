//
//  CommentsView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - CommentsView
//
// Page Commentaires accessible depuis un Promi. Design chrome cohérent avec
// PromiListView, DraftsView, KarmaView, AddPromiView, EditPromiView,
// SettingsView, OnboardingView, PromiCompositionShareView : PromiChromePageBackground
// (mood-aware) + cards chrome pour les bulles + accent orange sur "Commentaires"
// dans le titre. Input de saisie en chrome card avec bouton envoi orange.

struct CommentsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    let promiId: UUID

    @State private var newCommentText = ""

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

    // MARK: - Derived

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    private var comments: [Comment] {
        promiStore.comments.filter { $0.promiId == promiId }
    }

    private var canSend: Bool {
        !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

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

                    if comments.isEmpty {
                        emptyState
                    } else {
                        commentsList
                    }

                    composer
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Top header

    @ViewBuilder
    private var topHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                titleAttributed
                    .font(.system(size: 28, weight: .light))

                Text(isEnglish
                     ? "the conversation around this Promi"
                     : "la conversation autour de ce Promi")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.54))
            }

            Spacer()

            closeButton
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    /// "Commentaires" / "Comments" highlighted in brand orange.
    private var titleAttributed: Text {
        let raw = isEnglish ? "Comments" : "Commentaires"
        var attributed = AttributedString(raw)
        attributed.foregroundColor = brandOrange
        return Text(attributed)
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
                Text(isEnglish ? "Close" : "Fermer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.92))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(chromePill)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 76, height: 76)
                Circle()
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                    .frame(width: 76, height: 76)
                Text("💬")
                    .font(.system(size: 28))
                    .opacity(0.88)
            }

            VStack(spacing: 4) {
                Text(isEnglish ? "No comment yet" : "Aucun commentaire")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.72))

                Text(isEnglish
                     ? "be the first to say something"
                     : "sois le premier à t’exprimer")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.46))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Comments list

    @ViewBuilder
    private var commentsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(comments) { comment in
                    CommentRowView(comment: comment, brandOrange: brandOrange)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Composer (input + send)

    @ViewBuilder
    private var composer: some View {
        HStack(spacing: 10) {
            TextField(
                isEnglish ? "Add a comment…" : "ajouter un commentaire…",
                text: $newCommentText,
                axis: .vertical
            )
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(Color.white.opacity(0.92))
            .tint(brandOrange)
            .lineLimit(1...4)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(chromeCard)

            sendButton
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 26)
    }

    private var sendButton: some View {
        Button(action: addComment) {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.white.opacity(canSend ? 0.96 : 0.38))
                .frame(width: 42, height: 42)
                .background(
                    ZStack {
                        Circle()
                            .fill(
                                canSend
                                    ? brandOrange.opacity(0.86)
                                    : Color.white.opacity(0.06)
                            )
                        Circle()
                            .stroke(
                                canSend
                                    ? Color.white.opacity(0.22)
                                    : Color.white.opacity(0.12),
                                lineWidth: 0.6
                            )
                    }
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
    }

    // MARK: - Chrome helpers

    private var chromeCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
        }
    }

    private var chromePill: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.22))
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
    }

    // MARK: - Actions

    private func addComment() {
        guard canSend else { return }

        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)

        let comment = Comment(
            promiId: promiId,
            userId: userStore.localUserId,
            text: trimmed
        )

        promiStore.addComment(comment)
        newCommentText = ""
        Haptics.shared.lightTap()
    }
}

// MARK: - Comment row

private struct CommentRowView: View {
    @EnvironmentObject var userStore: UserStore
    let comment: Comment
    let brandOrange: Color

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(isEnglish ? "User" : "Utilisateur")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.88))

                Spacer()

                Text(comment.createdAt, style: .relative)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.48))
            }

            Text(comment.text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
            }
        )
    }
}
