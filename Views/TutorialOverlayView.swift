//
//  TutorialOverlayView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - TutorialOverlayView
//
// Overlay semi-transparent affiché au-dessus du home lors de la première
// visite. La carte du tutorial est positionnée selon `step.position` et
// pointe une flèche vers l'élément concerné selon `step.arrowDirection`.
// L'utilisateur voit immédiatement quel bouton on lui montre.
//
// Design chrome cohérent avec les autres pages : la card utilise les mêmes
// tokens (.ultraThinMaterial + white/0.05 + white/0.16 stroke) et le
// bouton primaire devient orange sur le dernier step. Le dim du fond est
// volontairement plus léger (0.58 vs 0.70 avant) pour laisser respirer
// le Voronoï du home en arrière-plan — l'utilisateur voit toujours le
// contexte qu'il apprend à manipuler.
//
// Navigation : tap anywhere OU tap bouton avance au step suivant. Sur le
// dernier step, le bouton devient « Terminé » en orange et ferme l'overlay.

struct TutorialOverlayView: View {
    @Binding var isPresented: Bool
    @Binding var currentStep: Int
    let steps: [TutorialStep]

    @EnvironmentObject var userStore: UserStore

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

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
        ZStack {
            // Dim backdrop — softer to keep the home Voronoï visible.
            Color.black.opacity(0.58)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { nextStep() }

            if let step = currentStepData {
                positionedCard(for: step)
            }

            VStack {
                Spacer()
                if steps.count > 1 {
                    stepIndicators
                        .padding(.bottom, 44)
                }
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: currentStep)
    }

    // MARK: Positioned card

    /// Place the card according to `step.position`. Each position uses a
    /// dedicated ZStack alignment + insets so the card sits next to the
    /// element it's pointing at:
    ///   .topLeading    → top-left, near the "Promi" brand button
    ///   .topTrailing   → top-right, near the "+" button
    ///   .bottomCenter  → bottom-center, near the dock
    ///   .center        → screen center, no specific anchor
    @ViewBuilder
    private func positionedCard(for step: TutorialStep) -> some View {
        let alignment = zStackAlignment(for: step.position)
        let insets = insets(for: step.position)

        ZStack(alignment: alignment) {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            tutorialCardWithArrow(for: step)
                .padding(.top, insets.top)
                .padding(.bottom, insets.bottom)
                .padding(.leading, insets.leading)
                .padding(.trailing, insets.trailing)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .id(currentStep)
        }
        .ignoresSafeArea()
    }

    private func zStackAlignment(for position: TutorialPosition) -> Alignment {
        switch position {
        case .topLeading:    return .topLeading
        case .topTrailing:   return .topTrailing
        case .bottomCenter:  return .bottom
        case .center:        return .center
        }
    }

    /// Insets that push the card AWAY from the screen edge it's anchored
    /// to. Top-anchored cards get a generous top padding to clear the
    /// status bar + the chrome anchor button it points at. Bottom-anchored
    /// cards leave room for the dock.
    private func insets(for position: TutorialPosition) -> EdgeInsets {
        switch position {
        case .topLeading:
            return EdgeInsets(top: 110, leading: 22, bottom: 0, trailing: 22)
        case .topTrailing:
            return EdgeInsets(top: 110, leading: 22, bottom: 0, trailing: 22)
        case .bottomCenter:
            return EdgeInsets(top: 0, leading: 22, bottom: 160, trailing: 22)
        case .center:
            return EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 28)
        }
    }

    // MARK: Tutorial card with arrow

    /// The card itself, decorated with an arrow on the side that points
    /// toward the anchor element. The arrow is rendered as a small filled
    /// triangle in the same brand color, positioned at the appropriate
    /// edge of the card.
    @ViewBuilder
    private func tutorialCardWithArrow(for step: TutorialStep) -> some View {
        VStack(spacing: 0) {
            if step.arrowDirection == .up {
                arrowGlyph(for: .up)
                    .padding(.bottom, -2)
            }

            HStack(spacing: 0) {
                if step.arrowDirection == .left {
                    arrowGlyph(for: .left)
                        .padding(.trailing, -2)
                }

                tutorialCard(for: step)

                if step.arrowDirection == .right {
                    arrowGlyph(for: .right)
                        .padding(.leading, -2)
                }
            }

            if step.arrowDirection == .down {
                arrowGlyph(for: .down)
                    .padding(.top, -2)
            }
        }
    }

    /// Small filled triangle in brand orange, pointing in the given
    /// direction. Used as the arrow that connects the tutorial card to
    /// the UI element it's describing.
    @ViewBuilder
    private func arrowGlyph(for direction: ArrowDirection) -> some View {
        let symbolName: String = {
            switch direction {
            case .up:    return "arrowtriangle.up.fill"
            case .down:  return "arrowtriangle.down.fill"
            case .left:  return "arrowtriangle.left.fill"
            case .right: return "arrowtriangle.right.fill"
            case .none:  return ""
            }
        }()

        if !symbolName.isEmpty {
            Image(systemName: symbolName)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(brandOrange.opacity(0.86))
                .shadow(color: .black.opacity(0.32), radius: 4, x: 0, y: 1)
        }
    }

    // MARK: Tutorial card body

    @ViewBuilder
    private func tutorialCard(for step: TutorialStep) -> some View {
        VStack(spacing: 16) {
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
                                    ? brandOrange.opacity(0.86)
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
        .padding(.vertical, 22)
        .frame(maxWidth: 320)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 0.6)
            }
        )
        .shadow(color: .black.opacity(0.32), radius: 18, x: 0, y: 6)
    }

    /// Title with "Promi" highlighted in brand orange wherever it appears.
    private func titleText(for step: TutorialStep) -> Text {
        var attributed = AttributedString(step.title)
        attributed.font = .system(size: 18, weight: .semibold)
        attributed.foregroundColor = Color.white.opacity(0.96)

        if let range = attributed.range(of: "Promi") {
            attributed[range].foregroundColor = brandOrange
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

    // MARK: Step indicators

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

    // MARK: Actions

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
