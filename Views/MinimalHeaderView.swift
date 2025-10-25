//
//  MinimalHeaderView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct MinimalHeaderView: View {
    let textColor: Color
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Logo centré XL en haut
            Image("LogoPromi")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Plus grand : 60 → 100
            
            // "Promi" à gauche + "+" à droite (alignés au centre du logo)
            HStack(alignment: .center) {
                // "Promi" texte (toujours orange)
                Text("Promi")
                    .font(Typography.title1)
                    .foregroundColor(Brand.orange)
                
                Spacer()
                
                // Bouton + ultra-discret
                Button(action: {
                    Haptics.shared.lightTap()
                    onAddTap()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundColor(textColor)
                }
            }
            .padding(.top, Spacing.xs)
        }
    }
}
