//
//  NewHeaderView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct NewHeaderView: View {
    let onAddTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: Spacing.sm) {
            // Logo miniature
            Image("LogoPromi")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            // Texte "Promi" (non personnalisable, toujours orange)
            Text("Promi")
                .font(Typography.title1)
                .foregroundColor(Brand.orange)
            
            Spacer()
            
            // Bouton + noir (sans cercle)
            Button(action: {
                Haptics.shared.lightTap()
                onAddTap()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Brand.textPrimary)
            }
        }
    }
}
