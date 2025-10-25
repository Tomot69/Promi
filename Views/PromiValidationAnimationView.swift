//
//  PromiValidationAnimationView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct PromiValidationAnimationView: View {
    @Binding var isPresented: Bool
    
    @State private var handsScale: CGFloat = 0.5
    @State private var handsOpacity: Double = 0.0
    @State private var slapOffset: CGFloat = 0
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var checkmarkOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: Spacing.xl) {
                // Animation des mains qui "tapent"
                ZStack {
                    // Main gauche
                    Text("🤜")
                        .font(.system(size: 80))
                        .offset(x: -50 + slapOffset)
                        .scaleEffect(handsScale)
                        .opacity(handsOpacity)
                    
                    // Main droite
                    Text("🤛")
                        .font(.system(size: 80))
                        .offset(x: 50 - slapOffset)
                        .scaleEffect(handsScale)
                        .opacity(handsOpacity)
                    
                    // Checkmark de validation
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Brand.orange)
                        .scaleEffect(checkmarkScale)
                        .opacity(checkmarkOpacity)
                }
                .frame(height: 150)
                
                Text("Promi validé !")
                    .font(Typography.title3)
                    .foregroundColor(.white)
                    .opacity(checkmarkOpacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1 : Les mains apparaissent
        withAnimation(AnimationPreset.spring.delay(0.1)) {
            handsOpacity = 1.0
            handsScale = 1.0
        }
        
        // Phase 2 : Les mains se rapprochent (slap)
        withAnimation(AnimationPreset.springBouncy.delay(0.4)) {
            slapOffset = 40
        }
        
        // Haptic au moment du "slap"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Haptics.shared.success()
        }
        
        // Phase 3 : Checkmark apparaît
        withAnimation(AnimationPreset.spring.delay(0.7)) {
            checkmarkScale = 1.0
            checkmarkOpacity = 1.0
        }
        
        // Phase 4 : Les mains disparaissent
        withAnimation(AnimationPreset.easeOut.delay(1.0)) {
            handsOpacity = 0.0
        }
        
        // Phase 5 : Fermeture automatique
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            dismiss()
        }
    }
    
    private func dismiss() {
        withAnimation(AnimationPreset.easeOut) {
            isPresented = false
        }
    }
}
