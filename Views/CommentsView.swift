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
        promiStore.comments.filter { $0.promiId == promiId }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                userStore.selectedPalette.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if comments.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Circle()
                                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.08), lineWidth: 0.5)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("💬")
                                        .font(.system(size: 24))
                                )
                            
                            Text("Aucun commentaire")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                        }
                        
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(comments) { comment in
                                    CommentRowView(comment: comment)
                                }
                            }
                            .padding(24)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        TextField("Ajouter un commentaire...", text: $newCommentText)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.1), lineWidth: 0.5)
                            )
                        
                        Button(action: addComment) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(newCommentText.isEmpty ? userStore.selectedPalette.textSecondaryColor.opacity(0.3) : Brand.orange)
                        }
                        .disabled(newCommentText.isEmpty)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Commentaires")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(Brand.orange.opacity(0.85))
                    .font(.system(size: 15, weight: .regular))
                }
            }
        }
    }
    
    private func addComment() {
        let comment = Comment(
            promiId: promiId,
            userId: userStore.localUserId,
            text: newCommentText
        )
        
        promiStore.addComment(comment)
        newCommentText = ""
        Haptics.shared.lightTap()
    }
}

// MARK: - Comment Row View
struct CommentRowView: View {
    @EnvironmentObject var userStore: UserStore
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Utilisateur")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.7))
                
                Spacer()
                
                Text(comment.createdAt, style: .relative)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
            }
            
            Text(comment.text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.06), lineWidth: 0.2)
        )
    }
}
