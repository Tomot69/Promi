//
//  TutorialOverlayView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct TutorialOverlayView: View {
    @Binding var isPresented: Bool
    @Binding var currentStep: Int
    let steps: [TutorialStep]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    nextStep()
                }
            
            VStack {
                Spacer()
                
                if currentStep < steps.count {
                    let step = steps[currentStep]
                    
                    VStack(spacing: 16) {
                        Text(step.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(step.message)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Button(action: nextStep) {
                            Text(currentStep == steps.count - 1 ? "Terminé" : "Suivant")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Brand.orange)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white)
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.9))
                    )
                    .padding(.horizontal, 32)
                }
                
                Spacer()
            }
        }
    }
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation(Animation.easeOut(duration: 0.3)) {
                currentStep += 1
            }
            Haptics.shared.lightTap()
        } else {
            withAnimation(Animation.easeOut(duration: 0.3)) {
                isPresented = false
            }
            Haptics.shared.success()
        }
    }
}
