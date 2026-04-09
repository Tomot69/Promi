//
//  MinimalIntensityGaugeView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - MinimalIntensityGaugeView
//
// Composant gauge d'intensité utilisé par AddPromiView et EditPromiView.
// Slider 0–100 + cœur progressif qui se dessine en deux moitiés au fur et
// à mesure que l'intensité monte + label vibey en anglais ("meh", "kinda",
// "yes", "really", "badly", "on my soul") qui exprime la charge émotionnelle.
//
// Les labels anglais sont une identité produit délibérée — c'est du
// vocabulaire de jeune adulte qui exprime mieux l'intensité d'une promesse
// que des équivalents français plats. Ils restent en anglais quelle que
// soit la langue de l'app.
//
// Le composant accepte un paramètre `textColor` que les pages chrome lui
// passent en `Color.white.opacity(0.66)` pour rester cohérent avec leur
// identité. Le textColor est utilisé directement (sans multiplicateur
// d'opacité) pour respecter la valeur fournie par le parent.

struct MinimalIntensityGaugeView: View {
    @Binding var intensity: Int
    let question: String
    let textColor: Color

    @State private var lastHapticValue = 0
    @State private var heartStroke1: CGFloat = 0.0
    @State private var heartStroke2: CGFloat = 0.0

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

    /// Vibey English-only intensity labels — intentionally kept in English
    /// across all locales as a product identity choice. These express the
    /// emotional weight of a promise better than literal translations.
    private var intensityLabel: String {
        switch intensity {
        case 0..<20:  return "meh"
        case 20..<40: return "kinda"
        case 40..<60: return "yes"
        case 60..<80: return "really"
        case 80..<95: return "badly"
        default:      return "on my soul"
        }
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question — uses textColor directly (parent passes the
            // already-muted opacity, no further dimming).
            Text(question)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)

            // Vibey intensity label — orange brand accent, centered
            Text(intensityLabel)
                .font(.system(size: 12, weight: .medium))
                .italic()
                .foregroundColor(brandOrange.opacity(0.92))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 2)
                .animation(.spring(response: 0.28, dampingFraction: 0.82), value: intensityLabel)

            HStack(spacing: 16) {
                progressiveHeart
                intensitySlider
            }
        }
        .onAppear {
            updateHeartStrokes(for: intensity)
        }
    }

    // MARK: Progressive heart (two halves drawn in sequence)

    private var progressiveHeart: some View {
        ZStack {
            HeartStrokePath(isLeft: true)
                .trim(from: 0, to: heartStroke1)
                .stroke(
                    brandOrange.opacity(0.78),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 40, height: 40)

            HeartStrokePath(isLeft: false)
                .trim(from: 0, to: heartStroke2)
                .stroke(
                    brandOrange.opacity(0.78),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 40, height: 40)
        }
        .frame(width: 40, height: 40)
    }

    // MARK: Slider (uses .tint, the modern API)

    private var intensitySlider: some View {
        Slider(
            value: Binding(
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
            ),
            in: 0...100,
            step: 1
        )
        .tint(brandOrange.opacity(0.78))
    }

    // MARK: Heart drawing logic

    private func updateHeartStrokes(for value: Int) {
        let progress = CGFloat(value) / 100.0

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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

// MARK: - Heart stroke path (one half of a heart)

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
