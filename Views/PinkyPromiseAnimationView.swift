//
//  PinkyPromiseAnimationView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct PinkyPromiseAnimationView: View {
    let onComplete: () -> Void
    
    @State private var finger1Offset: CGFloat = -100
    @State private var finger2Offset: CGFloat = 100
    @State private var finger1Rotation: Double = -30
    @State private var finger2Rotation: Double = 30
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Deux doigts en pinky
                ZStack {
                    Text("🤙")
                        .font(.system(size: 80))
                        .rotationEffect(.degrees(finger1Rotation))
                        .offset(x: finger1Offset)
                    
                    Text("🤙")
                        .font(.system(size: 80))
                        .scaleEffect(x: -1, y: 1)
                        .rotationEffect(.degrees(finger2Rotation))
                        .offset(x: finger2Offset)
                    
                    if showCheckmark {
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundColor(Brand.orange)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 120)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1: Doigts se rapprochent
        withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            finger1Offset = -10
            finger2Offset = 10
            finger1Rotation = -10
            finger2Rotation = 10
        }
        
        // Phase 2: Contact (haptic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Haptics.shared.success()
        }
        
        // Phase 3: Checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.6)) {
                showCheckmark = true
            }
        }
        
        // Phase 4: Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onComplete()
        }
    }
}
