//
//  CommentsView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    
    let promiId: UUID
    
    @State private var newCommentText = ""
    
    private var comments: [Comment] {
        promiStore.getComments(for: promiId)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                userStore.selectedPalette.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Comments list
                    if comments.isEmpty {
                        Spacer()
                        VStack(spacing: Spacing.md) {
                            Text("💬")
                                .font(.system(size: 60))
                            
                            Text(userStore.selectedLanguage.starts(with: "en") ? "No comments yet" : "Aucun commentaire")
                                .font(Typography.callout)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.6))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: Spacing.md) {
                                ForEach(comments) { comment in
                                    CommentBubbleView(comment: comment)
                                }
                            }
                            .padding(Spacing.lg)
                        }
                    }
                    
                    // Input area (ultra-minimal)
                    HStack(spacing: Spacing.md) {
                        TextField(
                            userStore.selectedLanguage.starts(with: "en") ? "Add a comment..." : "Ajouter un commentaire...",
                            text: $newCommentText,
                            axis: .vertical
                        )
                        .font(Typography.callout)
                        .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                        .lineLimit(3)
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.1), lineWidth: 0.3)
                        )
                        
                        Button(action: addComment) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(newCommentText.isEmpty ? userStore.selectedPalette.textSecondaryColor.opacity(0.3) : Brand.orange)
                        }
                        .disabled(newCommentText.isEmpty)
                    }
                    .padding(Spacing.lg)
                    .background(
                        userStore.selectedPalette.backgroundColor
                            .shadow(color: Color.black.opacity(0.05), radius: 8, y: -2)
                    )
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(userStore.selectedLanguage.starts(with: "en") ? "Close" : "Fermer") {
                        dismiss()
                    }
                    .foregroundColor(Brand.orange)
                }
            }
        }
    }
    
    private func addComment() {
        guard !newCommentText.isEmpty else { return }
        
        let trimmedText = String(newCommentText.prefix(240))
        
        let comment = Comment(
            promiId: promiId,
            authorId: userStore.localUserId,
            text: trimmedText
        )
        
        promiStore.addComment(comment)
        
        newCommentText = ""
        Haptics.shared.success()
    }
}

// MARK: - Comment Bubble View
struct CommentBubbleView: View {
    @EnvironmentObject var userStore: UserStore
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xs) {
                Text(String(comment.authorId.prefix(8)))
                    .font(Typography.caption2)
                    .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                
                Spacer()
                
                Text(comment.createdAt, style: .relative)
                    .font(Typography.caption2)
                    .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
            }
            
            Text(comment.text)
                .font(Typography.callout)
                .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xs)
                .fill(userStore.selectedPalette.textPrimaryColor.opacity(0.03))
        )
    }
}
