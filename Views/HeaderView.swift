//
//  HeaderView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct HeaderView: View {
    let karma: Int
    let roast: String
    let onAddTap: () -> Void
    
    @State private var logoPulse: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack(alignment: .center) {
                // Logo miniature à gauche
                Image("LogoPromi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .scaleEffect(logoPulse)
                    .onAppear {
                        // Pulse très subtil du logo (tamagotchi)
                        withAnimation(
                            Animation.easeInOut(duration: 3.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 5...10))
                        ) {
                            logoPulse = 1.03
                        }
                    }
                
                // Texte "Promi" en orange
                Text("Promi")
                    .font(Typography.title1)
                    .foregroundColor(Brand.orange)
                
                Spacer()
                
                // Bouton "+"
                Button(action: {
                    Haptics.shared.lightTap()
                    onAddTap()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Brand.orange)
                }
            }
            
            // Roast Strip (bande Karma)
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(karmaColor)
                    .frame(width: 8, height: 8)
                
                Text(roast)
                    .font(Typography.callout)
                    .foregroundColor(Brand.textSecondary)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(karma)%")
                    .font(Typography.caption)
                    .foregroundColor(Brand.textSecondary)
            }
        }
    }
    
    private var karmaColor: Color {
        if karma >= 90 {
            return Brand.karmaExcellent
        } else if karma >= 70 {
            return Brand.karmaGood
        } else if karma >= 50 {
            return Brand.karmaAverage
        } else {
            return Brand.karmaPoor
        }
    }
}
