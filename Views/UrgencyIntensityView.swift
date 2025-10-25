//
//  UrgencyIntensityView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct UrgencyIntensityView: View {
    @Binding var intensity: Int
    let question: String
    
    @State private var lastHapticValue = 0
    @State private var heartStroke1: CGFloat = 0.0
    @State private var heartStroke2: CGFloat = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Question
            Text(question)
                .font(Typography.callout)
                .foregroundColor(Brand.textSecondary)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: Spacing.md) {
                // Cœur progressif (2 coups de pinceau)
                ZStack {
                    // Coup de pinceau 1 (gauche)
                    HeartStrokePath(isLeft: true)
                        .trim(from: 0, to: heartStroke1)
                        .stroke(Brand.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                    
                    // Coup de pinceau 2 (droit)
                    HeartStrokePath(isLeft: false)
                        .trim(from: 0, to: heartStroke2)
                        .stroke(Brand.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                }
                .frame(width: 50, height: 50)
                
                // Slider
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Slider(value: Binding(
                        get: { Double(intensity) },
                        set: { newValue in
                            let rounded = Int(newValue)
                            intensity = rounded
                            updateHeartStrokes(for: rounded)
                            
                            // Haptic tous les 10%
                            if rounded / 10 != lastHapticValue / 10 {
                                Haptics.shared.lightTap()
                                lastHapticValue = rounded
                            }
                        }
                    ), in: 0...100, step: 1)
                    .accentColor(Brand.orange)
                    
                    Text("\(intensity)%")
                        .font(Typography.caption)
                        .foregroundColor(Brand.textSecondary)
                }
            }
        }
        .onAppear {
            updateHeartStrokes(for: intensity)
        }
    }
    
    private func updateHeartStrokes(for value: Int) {
        let progress = CGFloat(value) / 100.0
        
        withAnimation(AnimationPreset.spring) {
            if progress <= 0.5 {
                // 0-50% : Premier coup de pinceau (gauche)
                heartStroke1 = progress * 2.0
                heartStroke2 = 0.0
            } else {
                // 51-100% : Second coup de pinceau (droit)
                heartStroke1 = 1.0
                heartStroke2 = (progress - 0.5) * 2.0
            }
        }
    }
}

// MARK: - Heart Stroke Path (simplifié)
struct HeartStrokePath: Shape {
    let isLeft: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        if isLeft {
            // Coup gauche du cœur
            path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.8),
                control1: CGPoint(x: width * 0.1, y: height * 0.4),
                control2: CGPoint(x: width * 0.2, y: height * 0.7)
            )
        } else {
            // Coup droit du cœur
            path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.8),
                control1: CGPoint(x: width * 0.9, y: height * 0.4),
                control2: CGPoint(x: width * 0.8, y: height * 0.7)
            )
        }
        
        return path
    }
}
