//
//  PromiValidationAnimationView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct PromiValidationAnimationView: View {
    @Binding var isPresented: Bool
    
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var checkmarkRotation: Double = -45.0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    // Ring extérieur
                    Circle()
                        .stroke(Brand.orange.opacity(0.3), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .ultraLight))
                        .foregroundColor(Brand.orange)
                        .scaleEffect(checkmarkScale)
                        .rotationEffect(.degrees(checkmarkRotation))
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1: Ring appears
        withAnimation(Animation.easeOut(duration: 0.3)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }
        
        // Phase 2: Checkmark appears
        withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.6).delay(0.2)) {
            checkmarkScale = 1.0
            checkmarkRotation = 0.0
        }
        
        Haptics.shared.success()
        
        // Phase 3: Auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(Animation.easeOut(duration: 0.3)) {
                isPresented = false
            }
        }
    }
}
