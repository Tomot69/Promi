//
//  PromiKeptCelebrationView.swift
//  Promi
//

import SwiftUI

struct PromiKeptCelebrationView: View {
    @Binding var isPresented: Bool
    var karmaPercentage: Int = 0
    var isFrench: Bool = true

    @State private var splitOffset: CGFloat = 32
    @State private var haloScale: CGFloat = 0.6
    @State private var haloOpacity: Double = 0
    @State private var glyphOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var bgOpacity: Double = 0
    @State private var globalOpacity: Double = 1.0

    private var celebrationLine: String {
        if karmaPercentage >= 90 {
            return isFrench ? "signature." : "signature."
        } else if karmaPercentage >= 70 {
            return isFrench ? "solide." : "solid."
        } else if karmaPercentage >= 50 {
            return isFrench ? "ça monte." : "rising."
        } else if karmaPercentage >= 1 {
            return isFrench ? "c'est un début." : "it's a start."
        } else {
            return isFrench ? "ta parole tient." : "your word holds."
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(bgOpacity)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 20) {
                Spacer()

                ZStack {
                    // Halo
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Brand.orange.opacity(0.28),
                                    Brand.orange.opacity(0.06),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 4,
                                endRadius: 72
                            )
                        )
                        .frame(width: 144, height: 144)
                        .scaleEffect(haloScale)
                        .opacity(haloOpacity)

                    // Moitié gauche
                    PinkyPromiseGlyph(isDarkField: true)
                        .frame(width: 56, height: 56)
                        .clipShape(Rectangle().offset(x: -14))
                        .offset(x: -splitOffset)
                        .opacity(glyphOpacity)

                    // Moitié droite
                    PinkyPromiseGlyph(isDarkField: true)
                        .frame(width: 56, height: 56)
                        .clipShape(Rectangle().offset(x: 14))
                        .offset(x: splitOffset)
                        .opacity(glyphOpacity)
                }

                VStack(spacing: 6) {
                    Text(isFrench ? "Tenu" : "Kept")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(.white.opacity(0.92))
                        .tracking(0.8)

                    Text(celebrationLine)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Brand.orange.opacity(0.72))
                        .tracking(0.4)
                }
                .opacity(textOpacity)

                Spacer()
            }
        }
        .opacity(globalOpacity)
        .onAppear { runAnimation() }
    }

    private func runAnimation() {
        withAnimation(.easeOut(duration: 0.4)) {
            bgOpacity = 0.80
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
            glyphOpacity = 1.0
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.72).delay(0.35)) {
            splitOffset = 0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            haloOpacity = 1.0
            haloScale = 1.4
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.95)) {
            textOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 0.6).delay(1.3)) {
            haloScale = 1.1
            haloOpacity = 0.4
        }
        // Fondu global
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeInOut(duration: 0.6)) {
                globalOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                isPresented = false
            }
        }
    }
}
