//
//  PinkyPromiseAnimationView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct PinkyPromiseAnimationView: View {
    @State private var leftHandOffset: CGFloat = -200
    @State private var rightHandOffset: CGFloat = 200
    @State private var handsOpacity: Double = 0.0
    @State private var heartScale: CGFloat = 0.0
    @State private var heartOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var animationComplete = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Animation des mains
                ZStack {
                    // Main gauche (simplifiée)
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 100))
                        .foregroundColor(Brand.textPrimary)
                        .offset(x: leftHandOffset)
                        .opacity(handsOpacity)
                        .rotationEffect(.degrees(-30))
                    
                    // Main droite (simplifiée)
                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 100))
                        .foregroundColor(Brand.textPrimary)
                        .offset(x: rightHandOffset)
                        .opacity(handsOpacity)
                        .rotationEffect(.degrees(30))
                    
                    // Cœur au centre
                    Text("❤️")
                        .font(.system(size: 60))
                        .scaleEffect(heartScale)
                        .opacity(heartOpacity)
                }
                .frame(height: 200)
                
                // Texte
                VStack(spacing: Spacing.xs) {
                    Text("Pinky Promise")
                        .font(Typography.title2)
                        .foregroundColor(Brand.orange)
                        .opacity(textOpacity)
                    
                    Text("Tes Promis sont sacrés")
                        .font(Typography.callout)
                        .foregroundColor(Brand.textSecondary)
                        .opacity(textOpacity)
                }
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1 : Les mains apparaissent
        withAnimation(AnimationPreset.spring.delay(0.3)) {
            handsOpacity = 1.0
        }
        
        // Phase 2 : Les mains se rapprochent
        withAnimation(AnimationPreset.spring.delay(0.8)) {
            leftHandOffset = -40
            rightHandOffset = 40
        }
        
        // Phase 3 : Le cœur apparaît
        withAnimation(AnimationPreset.spring.delay(1.5)) {
            heartScale = 1.0
            heartOpacity = 1.0
        }
        
        // Phase 4 : Le texte apparaît
        withAnimation(AnimationPreset.easeOut.delay(2.0)) {
            textOpacity = 1.0
        }
        
        // Phase 5 : Haptic + transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            Haptics.shared.success()
            animationComplete = true
        }
        
        // Phase 6 : Navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(AnimationPreset.easeOut) {
                onComplete()
            }
        }
    }
}
