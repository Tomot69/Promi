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
    @State private var heartPulse: CGFloat = 1.0
    
    var body: some View {
        if isActive {
            LanguageSelectionView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    // Votre logo vectoriel
                    Image("LogoPromi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    // Texte "Promi" sous le logo
                    Text("Promi")
                        .font(Typography.title1)
                        .foregroundColor(Brand.orange)
                        .opacity(logoOpacity)
                }
            }
            .onAppear {
                // Animation d'entrée
                withAnimation(AnimationPreset.spring.delay(0.2)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                
                // Pulse subtil du cœur (optionnel)
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(0.5)
                ) {
                    heartPulse = 1.05
                }
                
                // Transition vers LanguageSelection après 2.5 secondes
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(AnimationPreset.easeOut) {
                        isActive = true
                    }
                }
            }
        }
    }
}
