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
    
    @State private var logoPulse: CGFloat = 1.0
    @State private var logoRotation: Double = 0.0
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Top bar : "Promi" à gauche + "+" à droite (symétriques)
            HStack(alignment: .center) {
                // "Promi" texte (orange subtil)
                Text("Promi")
                    .font(Typography.title2)
                    .foregroundColor(Brand.orange.opacity(0.85))
                
                Spacer()
                
                // Bouton + (orange invitant, comme le logo)
                Button(action: {
                    Haptics.shared.tinyPop()
                    onAddTap()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .ultraLight))
                        .foregroundColor(Brand.orange.opacity(0.85))
                }
            }
            
            // Logo centré XL (respire, pulse ultra-subtil + rotation micro)
            Image("LogoPromi")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120) // Plus grand : 100 → 120
                .scaleEffect(logoPulse)
                .rotationEffect(.degrees(logoRotation))
                .onAppear {
                    // Pulse ultra-subtil (tamagotchi)
                    withAnimation(
                        Animation.easeInOut(duration: 4.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        logoPulse = 1.015
                    }
                    
                    // Rotation micro (1 degré toutes les 6 secondes)
                    withAnimation(
                        Animation.easeInOut(duration: 6.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        logoRotation = 1.0
                    }
                }
        }
    }
}
