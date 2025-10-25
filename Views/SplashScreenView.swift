//
//  SplashScreenView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var heartPulse: CGFloat = 1.0
    
    var body: some View {
        if isActive {
            LanguageSelectionView()
        } else {
            ZStack {
                // Fond blanc pur
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    Spacer()
                    
                    // Logo vectoriel
                    Image("LogoPromi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .scaleEffect(logoScale * heartPulse)
                        .opacity(logoOpacity)
                    
                    // Phrase marquante
                    VStack(spacing: Spacing.xs) {
                        Text("Promi")
                            .font(Typography.title1)
                            .foregroundColor(Brand.orange)
                            .opacity(textOpacity)
                        
                        Text("L'art des petites promesses")
                            .font(Typography.callout)
                            .foregroundColor(Brand.textSecondary)
                            .opacity(textOpacity)
                    }
                    
                    Spacer()
                    Spacer()
                }
            }
            .onAppear {
                // Animation d'entrée du logo
                withAnimation(AnimationPreset.spring.delay(0.3)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                
                // Animation du texte
                withAnimation(AnimationPreset.easeOut.delay(0.8)) {
                    textOpacity = 1.0
                }
                
                // Pulse subtil du cœur (tamagotchi)
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatCount(2, autoreverses: true)
                        .delay(1.2)
                ) {
                    heartPulse = 1.05
                }
                
                // Transition vers LanguageSelection après 3 secondes
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                    withAnimation(AnimationPreset.easeOut) {
                        isActive = true
                    }
                }
            }
        }
    }
}
