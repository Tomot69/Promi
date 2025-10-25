//
//  MinimalIntensityGaugeView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct MinimalIntensityGaugeView: View {
    @Binding var intensity: Int
    let question: String
    let textColor: Color
    
    @State private var lastHapticValue = 0
    @State private var heartStroke1: CGFloat = 0.0
    @State private var heartStroke2: CGFloat = 0.0
    
    private var intensityLabel: String {
        switch intensity {
        case 0..<20: return "meh"
        case 20..<40: return "kinda"
        case 40..<60: return "yes"
        case 60..<80: return "really"
        case 80..<95: return "badly"
        default: return "on my soul"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Question
            Text(question)
                .font(Typography.caption)
                .foregroundColor(textColor.opacity(0.6))
            
            // Intensity label (apparaît au-dessus de la jauge)
            Text(intensityLabel)
                .font(Typography.caption2)
                .foregroundColor(Brand.orange.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, Spacing.xxs)
            
            HStack(spacing: Spacing.md) {
                // Cœur progressif (ultra-minimal)
                ZStack {
                    HeartStrokePath(isLeft: true)
                        .trim(from: 0, to: heartStroke1)
                        .stroke(Brand.orange.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 40, height: 40)
                    
                    HeartStrokePath(isLeft: false)
                        .trim(from: 0, to: heartStroke2)
                        .stroke(Brand.orange.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 40, height: 40)
                }
                .frame(width: 40, height: 40)
                
                // Slider ultra-minimal
                Slider(value: Binding(
                    get: { Double(intensity) },
                    set: { newValue in
                        let rounded = Int(newValue)
                        intensity = rounded
                        updateHeartStrokes(for: rounded)
                        
                        if rounded / 10 != lastHapticValue / 10 {
                            Haptics.shared.lightTap()
                            lastHapticValue = rounded
                        }
                    }
                ), in: 0...100, step: 1)
                .accentColor(Brand.orange.opacity(0.6))
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
                heartStroke1 = progress * 2.0
                heartStroke2 = 0.0
            } else {
                heartStroke1 = 1.0
                heartStroke2 = (progress - 0.5) * 2.0
            }
        }
    }
}

// MARK: - Heart Stroke Path
struct HeartStrokePath: Shape {
    let isLeft: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        if isLeft {
            path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.8),
                control1: CGPoint(x: width * 0.1, y: height * 0.4),
                control2: CGPoint(x: width * 0.2, y: height * 0.7)
            )
        } else {
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
