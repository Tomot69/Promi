//
//  CustomIcons.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - Custom Icons (temporaires - seront remplacés par PDF Figma)

struct DraftIcon: View {
    let color: Color
    let orangeDot: Bool
    
    var body: some View {
        ZStack {
            // Icône draft (feuille avec coin plié)
            Path { path in
                path.move(to: CGPoint(x: 6, y: 2))
                path.addLine(to: CGPoint(x: 18, y: 2))
                path.addLine(to: CGPoint(x: 18, y: 12))
                path.addLine(to: CGPoint(x: 22, y: 16))
                path.addLine(to: CGPoint(x: 22, y: 30))
                path.addLine(to: CGPoint(x: 6, y: 30))
                path.addLine(to: CGPoint(x: 6, y: 2))
                path.closeSubpath()
            }
            .stroke(color, lineWidth: 1.5)
            .frame(width: 28, height: 32)
            
            // Lignes intérieures
            VStack(spacing: 3) {
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(width: 10, height: 1)
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(width: 10, height: 1)
            }
            .offset(y: 2)
            
            // Point orange signature
            if orangeDot {
                Circle()
                    .fill(Brand.orange)
                    .frame(width: 3, height: 3)
                    .offset(x: 10, y: -10)
            }
        }
    }
}

struct PaletteIcon: View {
    let color: Color
    let orangeDot: Bool
    
    var body: some View {
        ZStack {
            // Palette (cercle avec arcs)
            Circle()
                .stroke(color, lineWidth: 1.5)
                .frame(width: 24, height: 24)
            
            // Arcs colorés (simplifiés)
            ForEach(0..<3) { index in
                Circle()
                    .trim(from: Double(index) * 0.3, to: Double(index) * 0.3 + 0.2)
                    .stroke(color.opacity(0.4), lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(Double(index) * 120))
            }
            
            // Point orange signature
            if orangeDot {
                Circle()
                    .fill(Brand.orange)
                    .frame(width: 3, height: 3)
                    .offset(x: 10, y: -8)
            }
        }
    }
}

struct KarmaIcon: View {
    let color: Color
    let orangeDot: Bool
    
    var body: some View {
        ZStack {
            // Graphique barres
            HStack(alignment: .bottom, spacing: 3) {
                Rectangle()
                    .fill(color.opacity(0.4))
                    .frame(width: 4, height: 12)
                Rectangle()
                    .fill(color.opacity(0.6))
                    .frame(width: 4, height: 18)
                Rectangle()
                    .fill(color)
                    .frame(width: 4, height: 24)
            }
            
            // Point orange signature
            if orangeDot {
                Circle()
                    .fill(Brand.orange)
                    .frame(width: 3, height: 3)
                    .offset(x: 10, y: -10)
            }
        }
    }
}

struct SettingsIcon: View {
    let color: Color
    let orangeDot: Bool
    
    var body: some View {
        ZStack {
            // Engrenage simplifié
            Circle()
                .stroke(color, lineWidth: 1.5)
                .frame(width: 20, height: 20)
            
            // Dents (6 rectangles)
            ForEach(0..<6) { index in
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: 4)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(index) * 60))
            }
            
            // Centre
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            // Point orange signature
            if orangeDot {
                Circle()
                    .fill(Brand.orange)
                    .frame(width: 3, height: 3)
                    .offset(x: 10, y: -8)
            }
        }
    }
}
