//
//  CommentsView.swift
//  Promi
//
//  Created on 24/10/2025.
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
            VStack(spacing: 0) {
                // Comments List
                if comments.isEmpty {
                    Spacer()
                    Text("Aucun commentaire")
                        .font(Typography.body)
                        .foregroundColor(Brand.textSecondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: Spacing.md) {
                            ForEach(comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                        .padding(Spacing.lg)
                    }
                }
                
                // Input Field
                HStack(spacing: Spacing.sm) {
                    TextField("Ajouter un commentaire...", text: $newCommentText)
                        .font(Typography.body)
                        .padding(Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(Color.gray.opacity(0.1))
                        )
                    
                    Button(action: addComment) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(newCommentText.isEmpty ? Brand.textSecondary : Brand.orange)
                    }
                    .disabled(newCommentText.isEmpty)
                }
                .padding(Spacing.lg)
                .background(Color.white)
            }
            .navigationTitle("Commentaires")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addComment() {
        guard !newCommentText.isEmpty else { return }
        
        let trimmed = String(newCommentText.prefix(240))
        promiStore.addComment(promiId: promiId, authorId: userStore.localUserId, text: trimmed)
        newCommentText = ""
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(comment.text)
                .font(Typography.body)
                .foregroundColor(Brand.textPrimary)
            
            Text(timeAgo(from: comment.createdAt))
                .font(Typography.caption)
                .foregroundColor(Brand.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        
        if days > 0 {
            return "Il y a \(days)j"
        } else if hours > 0 {
            return "Il y a \(hours)h"
        } else if minutes > 0 {
            return "Il y a \(minutes)min"
        } else {
            return "À l'instant"
        }
    }
}
