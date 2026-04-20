//
//  PromiKeptCelebrationView.swift
//  Promi
//

import SwiftUI

struct PromiKeptCelebrationView: View {
    @Binding var isPresented: Bool
    var karmaPercentage: Int = 0
    var isFrench: Bool = true
    var totalKept: Int = 0

    @State private var splitOffset: CGFloat = 32
    @State private var haloScale: CGFloat = 0.6
    @State private var haloOpacity: Double = 0
    @State private var glyphOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var bgOpacity: Double = 0
    @State private var globalOpacity: Double = 1.0

    private var isMilestone: Bool {
        [100, 500, 1000].contains(totalKept)
    }

    private var milestoneColor: Color {
        switch totalKept {
        case 1000: return Color(red: 1.0, green: 0.84, blue: 0.0)    // doré
        case 500:  return Color(red: 0.78, green: 0.78, blue: 0.82)   // argenté
        case 100:  return Color.white                                  // blanc
        default:   return Brand.orange
        }
    }

    private var celebrationLine: String {
        if totalKept == 1000 {
            return isFrench ? "légende." : "legend."
        } else if totalKept == 500 {
            return isFrench ? "demi-millier. respect." : "five hundred. respect."
        } else if totalKept == 100 {
            return isFrench ? "centième. rien ne t'arrête." : "one hundredth. unstoppable."
        } else if karmaPercentage >= 90 {
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
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (isMilestone ? milestoneColor : Brand.orange).opacity(0.18),
                                    (isMilestone ? milestoneColor : Brand.orange).opacity(0.04),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: 64
                            )
                        )
                        .frame(width: 128, height: 128)
                        .scaleEffect(haloScale)
                        .opacity(haloOpacity)

                    Circle()
                        .stroke((isMilestone ? milestoneColor : Brand.orange).opacity(isMilestone ? 0.28 : 0.14), lineWidth: isMilestone ? 1.0 : 0.6)
                        .frame(width: 80, height: 80)
                        .scaleEffect(haloScale)
                        .opacity(haloOpacity)

                    PinkyPromiseGlyph(isDarkField: true)
                        .frame(width: 48, height: 48)
                        .clipShape(Rectangle().offset(x: -12))
                        .offset(x: -splitOffset)
                        .opacity(glyphOpacity)

                    PinkyPromiseGlyph(isDarkField: true)
                        .frame(width: 48, height: 48)
                        .clipShape(Rectangle().offset(x: 12))
                        .offset(x: splitOffset)
                        .opacity(glyphOpacity)
                }

                VStack(spacing: 8) {
                    Text(isFrench ? "Tenu." : "Kept.")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white.opacity(0.90))
                        .tracking(1.0)
                        .opacity(textOpacity)

                    Text(celebrationLine)
                        .font(.system(size: 12, weight: isMilestone ? .medium : .regular))
                        .foregroundColor((isMilestone ? milestoneColor : Brand.orange).opacity(isMilestone ? 0.82 : 0.62))
                        .tracking(0.3)
                        .opacity(textOpacity)
                }

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
