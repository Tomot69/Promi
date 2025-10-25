//
//  PinkyPromiseSlightSlapView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct PinkyPromiseSlightSlapView: View {
    @Binding var isPresented: Bool
    
    @State private var finger1Offset: CGFloat = -30
    @State private var finger2Offset: CGFloat = 30
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var checkmarkOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // Deux doigts en pinky (ultra-minimal)
                ZStack {
                    // Doigt 1
                    Text("🤙")
                        .font(.system(size: 50))
                        .rotationEffect(.degrees(-30))
                        .offset(x: finger1Offset)
                    
                    // Doigt 2
                    Text("🤙")
                        .font(.system(size: 50))
                        .rotationEffect(.degrees(30))
                        .scaleEffect(x: -1, y: 1)
                        .offset(x: finger2Offset)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundColor(Brand.orange)
                        .scaleEffect(checkmarkScale)
                        .opacity(checkmarkOpacity)
                }
                .frame(height: 100)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1 : Les doigts se rapprochent (slap léger)
        withAnimation(AnimationPreset.springBouncy.delay(0.1)) {
            finger1Offset = -10
            finger2Offset = 10
        }
        
        // Haptic au moment du contact
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            Haptics.shared.gentleNudge()
        }
        
        // Phase 2 : Checkmark apparaît
        withAnimation(AnimationPreset.spring.delay(0.4)) {
            checkmarkScale = 1.0
            checkmarkOpacity = 1.0
        }
        
        // Phase 3 : Fermeture automatique
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(AnimationPreset.easeOut) {
                isPresented = false
            }
        }
    }
}
