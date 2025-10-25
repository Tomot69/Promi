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
        if currentStep < steps.count {
            ZStack {
                // Semi-transparent overlay
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        nextStep()
                    }
                
                // Tutorial card
                VStack(spacing: 0) {
                    if steps[currentStep].position == .topLeading || steps[currentStep].position == .topTrailing {
                        tutorialCard
                        Spacer()
                    } else if steps[currentStep].position == .bottomCenter {
                        Spacer()
                        tutorialCard
                    } else {
                        Spacer()
                        tutorialCard
                        Spacer()
                    }
                }
                .padding(Spacing.lg)
            }
            .transition(.opacity)
        }
    }
    
    private var tutorialCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(steps[currentStep].title)
                        .font(Typography.title3)
                        .foregroundColor(.white)
                    
                    Text(steps[currentStep].message)
                        .font(Typography.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: {
                    skipTutorial()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Progress dots
            HStack(spacing: Spacing.xs) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? Brand.orange : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                
                Spacer()
                
                if currentStep < steps.count - 1 {
                    Button(action: nextStep) {
                        Text("Suivant")
                            .font(Typography.callout)
                            .foregroundColor(Brand.orange)
                    }
                } else {
                    Button(action: completeTutorial) {
                        Text("Compris")
                            .font(Typography.callout)
                            .foregroundColor(Brand.orange)
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(Color.black.opacity(0.9))
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private func nextStep() {
        Haptics.shared.lightTap()
        withAnimation(AnimationPreset.spring) {
            currentStep += 1
        }
    }
    
    private func skipTutorial() {
        Haptics.shared.lightTap()
        withAnimation(AnimationPreset.easeOut) {
            isPresented = false
        }
    }
    
    private func completeTutorial() {
        Haptics.shared.success()
        withAnimation(AnimationPreset.easeOut) {
            isPresented = false
        }
    }
}
