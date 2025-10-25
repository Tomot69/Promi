//
//  DraftsView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct DraftsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    Spacer()
                    
                    Text("📝")
                        .font(.system(size: 60))
                    
                    Text("Drafts")
                        .font(Typography.title2)
                        .foregroundColor(Brand.textPrimary)
                    
                    Text("Aucun brouillon pour le moment")
                        .font(Typography.callout)
                        .foregroundColor(Brand.textSecondary)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(Brand.orange)
                }
            }
        }
    }
}
