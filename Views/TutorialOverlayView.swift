import SwiftUI

// MARK: - TutorialOverlayView
//
// 5 encarts qui présentent chaque icône du home. Chaque encart est un
// CALLOUT — une forme unique qui dessine la carte arrondie ET la pointe
// directionnelle comme un seul path continu (speech-bubble style).
// Aucune jonction visible, la pointe naît du bord de la carte.

struct TutorialOverlayView: View {
    @Binding var isPresented: Bool
    @Binding var currentStep: Int
    let steps: [TutorialStep]

    @EnvironmentObject var userStore: UserStore

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    private var isLastStep: Bool {
        currentStep >= steps.count - 1
    }

    private var currentStepData: TutorialStep? {
        guard currentStep >= 0, currentStep < steps.count else { return nil }
        return steps[currentStep]
    }

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            let screen = geo.size

            ZStack {
                Color.black.opacity(0.58)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { nextStep() }

                if let step = currentStepData {
                    positionedCallout(for: step, screen: screen)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        .id(currentStep)
                }

                VStack {
                    Spacer()
                    stepIndicators
                        .padding(.bottom, 58)
                }
            }
        }
        .ignoresSafeArea()
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: currentStep)
    }

    // MARK: - Icon center X (pixel-perfect)
    //
    // LAYOUT:
    //   Top-right cluster: [Nuées hex 46pt] (spacing 10) [Pinky 46pt]
    //   Bottom dock: [tri 46] [sp] [eye 46] [sp] [+ 54pt] [sp] [studio 46] [sp] [share 46]
    //   padding(.horizontal, 18), 4 spacers = (width - 36 - 238) / 4

    private func iconCenterX(for target: TutorialTarget, screen: CGSize) -> CGFloat {
        let side: CGFloat = 18
        let btn: CGFloat = 46

        switch target {
        case .addButton:
            return screen.width / 2

        case .promiListButton:
            return screen.width - side - btn / 2

        case .nuéesButton:
            return screen.width - side - btn - 10 - btn / 2

        case .karmaButton, .studioButton:
            let spacer = max(8, (screen.width - 36 - 238) / 4)
            if target == .karmaButton {
                return side + btn + spacer + btn / 2
            } else {
                return screen.width - side - btn - spacer - btn / 2
            }
        }
    }

    // MARK: - Positioned callout

    @ViewBuilder
    private func positionedCallout(for step: TutorialStep, screen: CGSize) -> some View {
        let iconX = iconCenterX(for: step.target, screen: screen)
        let alignment = zStackAlignment(for: step.position)
        let pad = insets(for: step.position, target: step.target)

        ZStack(alignment: alignment) {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            calloutView(for: step, iconX: iconX, screen: screen)
                .padding(.top, pad.top)
                .padding(.bottom, pad.bottom)
                .padding(.leading, pad.leading)
                .padding(.trailing, pad.trailing)
        }
    }

    // MARK: - Callout view (card + integrated pointer)
    //
    // One single shape draws everything. The pointer tip aims at the
    // icon's X coordinate. The card content sits inside with padding
    // that accounts for the pointer height on the relevant edge.

    @ViewBuilder
    private func calloutView(for step: TutorialStep, iconX: CGFloat, screen: CGSize) -> some View {
        let pad = insets(for: step.position, target: step.target)
        let cardW: CGFloat = min(320, screen.width - pad.leading - pad.trailing)
        let pointerH: CGFloat = 18

        // Card leading edge in screen coordinates
        let cardLeading: CGFloat = {
            switch step.position {
            case .topTrailing, .bottomTrailing:
                return screen.width - pad.trailing - cardW
            case .topLeading, .bottomLeading:
                return pad.leading
            case .bottomCenter, .center:
                return (screen.width - cardW) / 2
            }
        }()

        // Icon X in card-local coordinates, clamped for pointer base
        let iconInCard = iconX - cardLeading
        let clampedTipX = max(16, min(iconInCard, cardW - 16))

        let pointsUp = step.arrowDirection == .up

        let shape = CalloutShape(
            cornerRadius: 20,
            pointerOnTop: pointsUp,
            pointerTipX: clampedTipX,
            pointerHeight: pointerH,
            pointerBaseHalf: 12
        )

        // Card content with asymmetric padding for the pointer side
        VStack(spacing: 14) {
            titleText(for: step)
                .multilineTextAlignment(.center)

            Text(step.message)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: nextStep) {
                HStack(spacing: 6) {
                    Text(buttonText)
                        .font(.system(size: 13, weight: .semibold))
                    if !isLastStep {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                }
                .foregroundColor(Color.white.opacity(0.96))
                .padding(.horizontal, 22)
                .padding(.vertical, 11)
                .background(
                    ZStack {
                        Capsule(style: .continuous)
                            .fill(
                                isLastStep
                                    ? Brand.orange.opacity(0.86)
                                    : Color.white.opacity(0.10)
                            )
                        Capsule(style: .continuous)
                            .stroke(
                                isLastStep
                                    ? Color.white.opacity(0.22)
                                    : Color.white.opacity(0.18),
                                lineWidth: 0.6
                            )
                    }
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(.horizontal, 22)
        .padding(.top, pointsUp ? 20 + pointerH : 20)
        .padding(.bottom, pointsUp ? 20 : 20 + pointerH)
        .frame(width: cardW)
        .background(shape.fill(.ultraThinMaterial))
        .background(shape.fill(Color.white.opacity(0.05)))
        .overlay(shape.stroke(Brand.orange.opacity(0.36), lineWidth: 0.8))
        .shadow(color: .black.opacity(0.32), radius: 18, x: 0, y: 6)
    }

    // MARK: - Alignment & insets

    private func zStackAlignment(for position: TutorialPosition) -> Alignment {
        switch position {
        case .topLeading:     return .topLeading
        case .topTrailing:    return .topTrailing
        case .bottomLeading:  return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        case .bottomCenter:   return .bottom
        case .center:         return .center
        }
    }

    private func insets(for position: TutorialPosition, target: TutorialTarget) -> EdgeInsets {
        switch position {
        case .topLeading:
            return EdgeInsets(top: 110, leading: 18, bottom: 0, trailing: 18)
        case .topTrailing:
            // Both top-right encarts (Nuée step 1, Pinky step 3) sit lower
            // so the pointer reaches the icon cleanly. Pinky needs less
            // trailing padding because the pinky icon is the rightmost
            // element on screen — the callout shifts right to align.
            if target == .promiListButton {
                return EdgeInsets(top: 124, leading: 18, bottom: 0, trailing: 4)
            }
            return EdgeInsets(top: 124, leading: 18, bottom: 0, trailing: 12)
        case .bottomLeading:
            return EdgeInsets(top: 0, leading: 14, bottom: 128, trailing: 14)
        case .bottomTrailing:
            return EdgeInsets(top: 0, leading: 14, bottom: 128, trailing: 14)
        case .bottomCenter:
            return EdgeInsets(top: 0, leading: 14, bottom: 128, trailing: 14)
        case .center:
            return EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 28)
        }
    }

    // MARK: - Text helpers

    private func titleText(for step: TutorialStep) -> Text {
        var attributed = AttributedString(step.title)
        attributed.font = .system(size: 18, weight: .semibold)
        attributed.foregroundColor = Color.white.opacity(0.96)

        for keyword in ["Promi", "Nuée", "Karma", "Studio"] {
            if let range = attributed.range(of: keyword) {
                attributed[range].foregroundColor = Brand.orange
            }
        }

        return Text(attributed)
    }

    private var buttonText: String {
        if isLastStep {
            return isEnglish ? "Got it" : "Terminé"
        } else {
            return isEnglish ? "Next" : "Suivant"
        }
    }

    // MARK: - Step indicators

    private var stepIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentStep
                            ? Color.white.opacity(0.92)
                            : Color.white.opacity(0.24)
                    )
                    .frame(
                        width: index == currentStep ? 22 : 7,
                        height: 6
                    )
                    .animation(.spring(response: 0.32, dampingFraction: 0.84), value: currentStep)
            }
        }
    }

    // MARK: - Actions

    private func nextStep() {
        if currentStep < steps.count - 1 {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                currentStep += 1
            }
        } else {
            Haptics.shared.success()
            withAnimation(.easeOut(duration: 0.28)) {
                isPresented = false
            }
        }
    }
}

// MARK: - CalloutShape
//
// A rounded rectangle with a triangular pointer growing out of one
// edge — all as a SINGLE continuous path. No separate overlay, no
// junction gap. The pointer merges seamlessly into the card body
// because it IS part of the same bezier contour.
//
// Works like a speech bubble / tooltip arrow. The pointer tip can be
// positioned anywhere along the edge (via pointerTipX in local coords).

struct CalloutShape: Shape {
    let cornerRadius: CGFloat
    let pointerOnTop: Bool
    let pointerTipX: CGFloat
    let pointerHeight: CGFloat
    let pointerBaseHalf: CGFloat

    func path(in rect: CGRect) -> Path {
        let cr = min(cornerRadius, min(rect.width, rect.height) / 4)
        let ph = pointerHeight
        let bh = pointerBaseHalf

        // The card body rect (excludes the pointer protrusion)
        let cardRect: CGRect
        if pointerOnTop {
            cardRect = CGRect(x: rect.minX, y: rect.minY + ph,
                              width: rect.width, height: rect.height - ph)
        } else {
            cardRect = CGRect(x: rect.minX, y: rect.minY,
                              width: rect.width, height: rect.height - ph)
        }

        let minX = cardRect.minX
        let maxX = cardRect.maxX
        let minY = cardRect.minY
        let maxY = cardRect.maxY

        // Clamp pointer base within the straight portion of the edge
        let tipX = max(cr + bh + 2, min(pointerTipX, rect.width - cr - bh - 2))
        let baseL = tipX - bh
        let baseR = tipX + bh

        var p = Path()

        if pointerOnTop {
            // Start: top-left corner, end of arc
            p.move(to: CGPoint(x: minX + cr, y: minY))

            // Top edge → pointer notch → rest of top edge
            p.addLine(to: CGPoint(x: baseL, y: minY))
            p.addLine(to: CGPoint(x: tipX, y: rect.minY))
            p.addLine(to: CGPoint(x: baseR, y: minY))
            p.addLine(to: CGPoint(x: maxX - cr, y: minY))

            // Top-right corner
            p.addArc(center: CGPoint(x: maxX - cr, y: minY + cr),
                      radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0),
                      clockwise: false)

            // Right edge
            p.addLine(to: CGPoint(x: maxX, y: maxY - cr))

            // Bottom-right corner
            p.addArc(center: CGPoint(x: maxX - cr, y: maxY - cr),
                      radius: cr, startAngle: .degrees(0), endAngle: .degrees(90),
                      clockwise: false)

            // Bottom edge
            p.addLine(to: CGPoint(x: minX + cr, y: maxY))

            // Bottom-left corner
            p.addArc(center: CGPoint(x: minX + cr, y: maxY - cr),
                      radius: cr, startAngle: .degrees(90), endAngle: .degrees(180),
                      clockwise: false)

            // Left edge
            p.addLine(to: CGPoint(x: minX, y: minY + cr))

            // Top-left corner
            p.addArc(center: CGPoint(x: minX + cr, y: minY + cr),
                      radius: cr, startAngle: .degrees(180), endAngle: .degrees(270),
                      clockwise: false)

        } else {
            // Pointer on bottom

            // Start: top-left corner, end of arc
            p.move(to: CGPoint(x: minX + cr, y: minY))

            // Top edge
            p.addLine(to: CGPoint(x: maxX - cr, y: minY))

            // Top-right corner
            p.addArc(center: CGPoint(x: maxX - cr, y: minY + cr),
                      radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0),
                      clockwise: false)

            // Right edge
            p.addLine(to: CGPoint(x: maxX, y: maxY - cr))

            // Bottom-right corner
            p.addArc(center: CGPoint(x: maxX - cr, y: maxY - cr),
                      radius: cr, startAngle: .degrees(0), endAngle: .degrees(90),
                      clockwise: false)

            // Bottom edge → pointer notch (right to left)
            p.addLine(to: CGPoint(x: baseR, y: maxY))
            p.addLine(to: CGPoint(x: tipX, y: rect.maxY))
            p.addLine(to: CGPoint(x: baseL, y: maxY))
            p.addLine(to: CGPoint(x: minX + cr, y: maxY))

            // Bottom-left corner
            p.addArc(center: CGPoint(x: minX + cr, y: maxY - cr),
                      radius: cr, startAngle: .degrees(90), endAngle: .degrees(180),
                      clockwise: false)

            // Left edge
            p.addLine(to: CGPoint(x: minX, y: minY + cr))

            // Top-left corner
            p.addArc(center: CGPoint(x: minX + cr, y: minY + cr),
                      radius: cr, startAngle: .degrees(180), endAngle: .degrees(270),
                      clockwise: false)
        }

        p.closeSubpath()
        return p
    }
}
