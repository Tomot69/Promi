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
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Logo centré XL avec pulse ultra-subtil (tamagotchi)
            Image("LogoPromi")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .scaleEffect(logoPulse)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 4.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        logoPulse = 1.02
                    }
                }
            
            // "Promi" à gauche + "+" à droite (ultra-discrets)
            HStack(alignment: .center) {
                Text("Promi")
                    .font(Typography.title1)
                    .foregroundColor(Brand.orange.opacity(0.9))
                
                Spacer()
                
                Button(action: {
                    Haptics.shared.tinyPop()
                    onAddTap()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .ultraLight))
                        .foregroundColor(textColor.opacity(0.6))
                }
            }
            .padding(.top, Spacing.xxs)
        }
    }
}
