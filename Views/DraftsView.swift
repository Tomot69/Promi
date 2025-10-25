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
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Circle()
                            .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.08), lineWidth: 0.5)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("📝")
                                    .font(.system(size: 32))
                            )
                        
                        Text("Brouillons")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.8))
                        
                        Text("Aucun brouillon")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(draftStore.drafts) { draft in
                                DraftCardView(draft: draft)
                            }
                        }
                        .padding(32)
                    }
                }
            }
            .navigationTitle("")
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
}

struct DraftCardView: View {
    @EnvironmentObject var userStore: UserStore
    let draft: PromiDraft
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(draft.title.isEmpty ? "Sans titre" : draft.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.8))
            
            Text(draft.createdAt, style: .relative)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(userStore.selectedPalette.textSecondaryColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.06), lineWidth: 0.2)
        )
    }
}
