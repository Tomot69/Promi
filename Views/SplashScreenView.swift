//
//  SplashScreenView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        if isActive {
            LanguageSelectionView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    // Logo simplifié (on intégrera le vrai logo après)
                    Text("❤️")
                        .font(.system(size: 80))
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    Text("Promi")
                        .font(Typography.title1)
                        .foregroundColor(Brand.orange)
                        .opacity(logoOpacity)
                }
            }
            .onAppear {
                withAnimation(AnimationPreset.spring) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(AnimationPreset.easeOut) {
                        isActive = true
                    }
                }
            }
        }
    }
}
