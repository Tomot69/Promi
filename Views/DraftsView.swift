//
//  DraftsView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct DraftsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var draftStore: DraftStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        NavigationView {
            ZStack {
                userStore.selectedPalette.backgroundColor
                    .ignoresSafeArea()
                
                if draftStore.drafts.isEmpty {
                    VStack(spacing: Spacing.xl) {
                        Spacer()
                        
                        Text("📝")
                            .font(.system(size: 60))
                        
                        Text("Drafts")
                            .font(Typography.title3)
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                        
                        Text(userStore.selectedLanguage.starts(with: "en") ? "No drafts yet" : "Aucun brouillon")
                            .font(Typography.callout)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.6))
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            ForEach(draftStore.drafts) { draft in
                                DraftCardView(draft: draft)
                            }
                        }
                        .padding(Spacing.xl)
                    }
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
}

struct DraftCardView: View {
    @EnvironmentObject var userStore: UserStore
    let draft: PromiDraft
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(draft.title.isEmpty ? "Sans titre" : draft.title)
                .font(Typography.body)
                .foregroundColor(userStore.selectedPalette.textPrimaryColor)
            
            Text(draft.createdAt, style: .relative)
                .font(Typography.caption2)
                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xs)
                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.1), lineWidth: 0.3)
        )
    }
}
