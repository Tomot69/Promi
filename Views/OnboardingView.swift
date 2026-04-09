import SwiftUI

// MARK: - Slide model (local, self-contained — no dependency on legacy OnboardingContent)

/// Fully local onboarding slide model. Keeping the slide definitions inside
/// OnboardingView gives us full control over the copy and avoids having to
/// coordinate with the legacy `OnboardingContent` string table. The 4 slides
/// below are the canonical Promi onboarding script.
private struct PromiOnboardingSlide: Identifiable {
    enum Shape {
        case concept   // 3 voronoi-like blobs — the "engagement zones" metaphor
        case karma     // a scale / a star — the karma metaphor
        case premium   // a soft pink + orange + black composition
        case account   // local storage metaphor — 3 blocks nesting
    }

    let id = UUID()
    let title: String
    let body: String
    let examples: [String]
    let shape: Shape
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @Environment(\.dismiss) private var dismiss

    @AppStorage("promi.visualPack") private var visualPackRawValue: String =
        PromiVisualPack.alveolesSignature.rawValue
    @AppStorage("promi.visualMood") private var visualMoodRawValue: String =
        PromiColorMood.terrePromi.rawValue

    @State private var currentPage: Int = 0

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    private var slides: [PromiOnboardingSlide] {
        isFrench ? Self.frenchSlides : Self.englishSlides
    }

    // MARK: Body

    var body: some View {
        ZStack {
            // Chrome identique aux autres pages — mood-aware, même recette
            // que le CompactMenuSurface des dropdown tri/+ du home.
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 0) {
                topBar

                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        PromiOnboardingSlideView(slide: slide, brandOrange: brandOrange)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { oldValue, newValue in
                    // Haptic feedback on every page change — whether from
                    // native swipe, from the "Suivant" button, or from the
                    // "Passer" skip button. Keeps the interaction tactile
                    // on every transition without double-tapping on the
                    // ones that already fire a haptic (handleNext, skip).
                    if oldValue != newValue {
                        Haptics.shared.lightTap()
                    }
                }

                indicators

                nextButton
            }
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(alignment: .center) {
            // « Promi » en orange — même accent identité que les autres pages.
            Text("Promi")
                .font(.system(size: 22, weight: .light))
                .foregroundColor(brandOrange)

            Spacer()

            // Skip button — chrome pill style.
            Button(action: skipToLast) {
                Text(isFrench ? "Passer" : "Skip")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.72))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(chromePill)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 6)
    }

    // MARK: Page indicators

    private var indicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<slides.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? Color.white.opacity(0.88)
                            : Color.white.opacity(0.18)
                    )
                    .frame(
                        width: index == currentPage ? 26 : 8,
                        height: 7
                    )
                    .animation(
                        .spring(response: 0.32, dampingFraction: 0.82),
                        value: currentPage
                    )
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
    }

    // MARK: Next / Enter button

    private var nextButton: some View {
        Button(action: handleNext) {
            HStack(spacing: 8) {
                Text(buttonText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.94))

                if !isLastSlide {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.86))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            isLastSlide
                                ? brandOrange.opacity(0.86)
                                : Color.white.opacity(0.08)
                        )
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            isLastSlide
                                ? Color.white.opacity(0.22)
                                : Color.white.opacity(0.16),
                            lineWidth: 0.6
                        )
                }
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 36)
    }

    private var buttonText: String {
        if isLastSlide {
            return isFrench ? "Entrer dans Promi" : "Enter Promi"
        } else {
            return isFrench ? "Suivant" : "Next"
        }
    }

    private var isLastSlide: Bool {
        currentPage >= slides.count - 1
    }

    // MARK: Chrome pill (reused for skip button)

    private var chromePill: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.22))
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
    }

    // MARK: Actions

    private func skipToLast() {
        // Haptic is fired by the onChange(of: currentPage) handler above.
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            currentPage = max(slides.count - 1, 0)
        }
    }

    private func handleNext() {
        if currentPage < slides.count - 1 {
            // Haptic is fired by the onChange(of: currentPage) handler above.
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                currentPage += 1
            }
        } else {
            // Final slide → no page change (onChange won't fire). Use the
            // richer success haptic to mark "crossing the threshold".
            Haptics.shared.success()
            userStore.completeOnboarding()
            // dismiss() pops the fullScreenCover when this is a replay
            // presented from Settings. In the normal entry flow the view
            // is part of the main hierarchy (not presented) and dismiss
            // is a no-op — completeOnboarding above handles the transition
            // via the observed hasCompletedOnboarding flag.
            dismiss()
        }
    }

    // MARK: Canonical slide content (French)

    private static let frenchSlides: [PromiOnboardingSlide] = [
        PromiOnboardingSlide(
            title: "Un Promi, c’est quoi ?",
            body: "Une promesse. À soi-même, ou à quelqu’un. Précise dans le temps, ou simplement en l’air.",
            examples: [
                "« Je t’emmène à la mer »",
                "« Je te rends ton chargeur jaune lundi 18h »",
                "« J’appelle Maman samedi matin »",
                "« Je me remets au piano »"
            ],
            shape: .concept
        ),
        PromiOnboardingSlide(
            title: "Votre Karma, c’est vous.",
            body: "Chaque Promi tenu renforce votre parole. Chaque Promi oublié la fragilise.",
            examples: [
                "90–100 %  —  t’es une légende",
                "70–89 %    —  solide, régulier",
                "50–69 %    —  ça va, ça vient",
                "moins de 50 %  —  on en reparle ?"
            ],
            shape: .karma
        ),
        PromiOnboardingSlide(
            title: "Promi Premium",
            body: "Un jour, pour celles et ceux qui veulent aller plus loin : partage, groupes, rappels intelligents. Pour l’instant, tout est gratuit.",
            examples: [],
            shape: .premium
        ),
        PromiOnboardingSlide(
            title: "Votre espace, local.",
            body: "Vos Promi restent sur votre appareil. Pas de compte, pas de serveur, pas de publicité. Juste vous et vos promesses.",
            examples: [],
            shape: .account
        )
    ]

    // MARK: Canonical slide content (English)

    private static let englishSlides: [PromiOnboardingSlide] = [
        PromiOnboardingSlide(
            title: "What’s a Promi?",
            body: "A promise. To yourself, or to someone. Sometimes with a precise moment. Sometimes just floating in the air.",
            examples: [
                "“I’ll take you to the sea”",
                "“I’ll return your yellow charger Monday at 6”",
                "“I’ll call Mom Saturday morning”",
                "“I’ll get back to the piano”"
            ],
            shape: .concept
        ),
        PromiOnboardingSlide(
            title: "Your Karma is you.",
            body: "Every Promi kept strengthens your word. Every Promi forgotten weakens it.",
            examples: [
                "90–100 %  —  you’re a legend",
                "70–89 %    —  solid and steady",
                "50–69 %    —  it goes, it comes",
                "under 50 %  —  let’s have that talk"
            ],
            shape: .karma
        ),
        PromiOnboardingSlide(
            title: "Promi Premium",
            body: "One day, for those who want to go further: sharing, groups, smart reminders. For now, everything is free.",
            examples: [],
            shape: .premium
        ),
        PromiOnboardingSlide(
            title: "Your space, local.",
            body: "Your Promis stay on your device. No account, no server, no ads. Just you and your promises.",
            examples: [],
            shape: .account
        )
    ]
}

// MARK: - Slide view

private struct PromiOnboardingSlideView: View {
    let slide: PromiOnboardingSlide
    let brandOrange: Color

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 14)

                // Chrome card with abstract shape composition.
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 200, height: 230)
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                        .frame(width: 200, height: 230)

                    onboardingShape(for: slide.shape)
                }

                // Title: « Promi » highlighted in orange if present.
                titleText
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                // Body: full text, no line limit, no truncation.
                Text(slide.body)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.74))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)

                if !slide.examples.isEmpty {
                    examplesList
                }

                Spacer(minLength: 14)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Title with Promi orange accent

    private var titleText: Text {
        var attributed = AttributedString(slide.title)
        attributed.font = .system(size: 26, weight: .light)
        attributed.foregroundColor = Color.white.opacity(0.94)

        // Highlight "Promi" in brandOrange wherever it appears in the title.
        if let range = attributed.range(of: "Promi") {
            attributed[range].foregroundColor = brandOrange
        }

        return Text(attributed)
    }

    // MARK: Examples list

    private var examplesList: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(slide.examples, id: \.self) { example in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(brandOrange.opacity(0.58))
                        .frame(width: 4, height: 4)
                        .padding(.top, 7)

                    Text(example)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.64))
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 38)
        .padding(.top, 2)
    }

    // MARK: Abstract shapes

    @ViewBuilder
    private func onboardingShape(for shape: PromiOnboardingSlide.Shape) -> some View {
        switch shape {
        case .concept:
            ZStack {
                // Orange solid rectangle = precise Promi: a pinned moment with
                // sharp edges, a clear boundary in time. Full opacity fill.
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.08).opacity(0.92))
                    .frame(width: 96, height: 82)
                    .offset(x: -28, y: -30)

                // Blue rectangle = floating Promi: an intention that drifts in
                // time with no fixed anchor. The linear gradient fading out
                // toward the bottom visually evokes the "en l'air" quality —
                // the shape exists, it's a real commitment, but it doesn't
                // have a hard edge in time.
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.14, green: 0.46, blue: 0.96).opacity(0.94),
                                Color(red: 0.14, green: 0.46, blue: 0.96).opacity(0.38)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 90, height: 92)
                    .offset(x: 32, y: 14)

                // Black circle = the person — self or other — at the center
                // of both commitments.
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 66, height: 66)
            }

        case .karma:
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.84, blue: 0.08).opacity(0.95))
                    .frame(width: 118, height: 82)
                    .offset(x: 10, y: -24)
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 72, height: 72)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.75, blue: 0.48).opacity(0.92))
                    .frame(width: 104, height: 72)
                    .offset(x: -16, y: 42)
            }

        case .premium:
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.78, blue: 0.84).opacity(0.82))
                    .frame(width: 100, height: 122)
                    .offset(x: -18, y: -8)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.08).opacity(0.92))
                    .frame(width: 88, height: 82)
                    .offset(x: 30, y: 36)
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 64, height: 64)
            }

        case .account:
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.75, blue: 0.48).opacity(0.92))
                    .frame(width: 106, height: 82)
                    .offset(x: -24, y: 34)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.14, green: 0.46, blue: 0.96).opacity(0.92))
                    .frame(width: 94, height: 112)
                    .offset(x: 26, y: -10)
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 68, height: 68)
            }
        }
    }
}
