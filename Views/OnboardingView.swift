import SwiftUI

// MARK: - Slide model (local, self-contained — no dependency on legacy OnboardingContent)

/// Fully local onboarding slide model. Keeping the slide definitions inside
/// OnboardingView gives us full control over the copy and avoids having to
/// coordinate with the legacy `OnboardingContent` string table. The 4 slides
/// below are the canonical Promi onboarding script.
private struct PromiOnboardingSlide: Identifiable {
    enum Shape {
        case concept   // 3 voronoi-like blobs — the "engagement zones" metaphor
        case social    // the send→receive→keep→bravo flow
        case karma     // a scale / a star — the karma metaphor
        case nuées     // thematic + intimate Nuées — two orbs, one enclosing a smaller
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
                        PromiOnboardingSlideView(slide: slide)
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
                .foregroundColor(Brand.orange)

            Spacer()

            // Skip button — chrome pill style. Hidden on the last slide
            // because there's nothing left to skip: the user is already
            // at the final step and the primary CTA is "Entrer dans Promi".
            if !isLastSlide {
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
                                ? Brand.orange.opacity(0.86)
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
                title: "Un Promi, c'est quoi ?",
                body: "Une promesse. À soi-même, ou à quelqu'un. Précise dans le temps, ou simplement en l'air.",
                examples: [
                    "« Je t'emmène à la mer »",
                    "« Je te rends ton chargeur jaune lundi 18h »",
                    "« J'appelle Maman samedi matin »",
                    "« Je me remets au piano »"
                ],
                shape: .concept
            ),
            PromiOnboardingSlide(
                title: "Comment ça marche ?",
                body: "Promi, c'est un contrat social. Tu envoies une promesse, l'autre la reçoit, et quand elle est tenue, il le dit.",
                examples: [
                    "1. Tu crées un Promi → tu l'envoies à quelqu'un",
                    "2. Il le reçoit dans sa toile → il sait ce que tu as promis",
                    "3. Tu le tiens → tu le marques comme tenu",
                    "4. Il te bravo → ton Karma monte"
                ],
                shape: .social
            ),
            PromiOnboardingSlide(
                title: "Votre Karma, c'est vous.",
                body: "Chaque Promi tenu renforce votre parole. Chaque Promi oublié la fragilise.",
                examples: [
                    "90–100 %  —  ta parole vaut signature",
                    "70–89 %    —  fiable, tu tiens",
                    "50–69 %    —  ça va, ça vient",
                    "moins de 50 %  —  on en reparle ?"
                ],
                shape: .karma
            ),
            PromiOnboardingSlide(
                title: "Les Nuées, vos cercles.",
                body: "Une Nuée réunit plusieurs personnes qui se promettent des choses ensemble. *Thématique* pour fédérer un groupe autour d'un sujet. Ou *Intime* pour créer un cercle proche et libre — famille, amis, couple — où chacun peut lancer ses propres thèmes.",
                examples: [
                    "Amis proches  →  « Weekend Lisbonne »  +  « 30 ans Léo »",
                    "Famille  →  « Vacances été »  +  « Noël à Lyon »",
                    "Thématique ouverte  —  « Sport 2026 » avec des amis sportifs",
                    "Thématique ouverte  —  « Projet studio » avec vos collaborateurs"
                ],
                shape: .nuées
            ),
            PromiOnboardingSlide(
                title: "Promi Plus",
                body: "Pour celles et ceux qui veulent aller plus loin. Promi et Nuées illimités, social complet, rappels intelligents.",
                examples: [
                    "5 Promi / jour gratuits — Plus = illimité",
                    "2 Nuées gratuites — Plus = illimité",
                    "2,99 € / mois ou 19,99 € / an"
                ],
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
                title: "What's a Promi?",
                body: "A promise. To yourself, or to someone. Sometimes with a precise moment. Sometimes just floating in the air.",
                examples: [
                                "\"I'll take you to the sea\"",
                                "\"I'll return your yellow charger Monday at 6\"",
                                "\"I'll call Mom Saturday morning\"",
                                "\"I'll get back to the piano\""
                            ],
                shape: .concept
            ),
            PromiOnboardingSlide(
                title: "How does it work?",
                body: "Promi is a social contract. You send a promise, the other receives it, and when it's kept, they acknowledge it.",
                examples: [
                    "1. You create a Promi → you send it to someone",
                    "2. They receive it → they see what you promised",
                    "3. You keep it → you mark it as done",
                    "4. They bravo you → your Karma goes up"
                ],
                shape: .social
            ),
            PromiOnboardingSlide(
                title: "Your Karma is you.",
                body: "Every Promi kept strengthens your word. Every Promi forgotten weakens it.",
                examples: [
                    "90–100 %  —  your word is signature",
                    "70–89 %    —  reliable, you keep them",
                    "50–69 %    —  it goes, it comes",
                    "under 50 %  —  let's have that talk"
                ],
                shape: .karma
            ),
            PromiOnboardingSlide(
                title: "Nuées are your circles.",
                body: "A Nuée brings together several people who make promises to each other. *Thematic* to rally a group around a subject. Or *Intimate* to create a close and free circle — family, friends, partner — where anyone can start their own themes.",
                examples: [
                                "Close friends  →  \"Lisbon weekend\"  +  \"Leo's birthday\"",
                                "Family  →  \"Summer holidays\"  +  \"Christmas in Lyon\"",
                                "Open thematic  —  \"Sport 2026\" with workout friends",
                                "Open thematic  —  \"Studio project\" with collaborators"
                            ],
                shape: .nuées
            ),
            PromiOnboardingSlide(
                title: "Promi Plus",
                body: "For those who want to go further. Unlimited Promis and Nuées, full social, smart reminders.",
                examples: [
                    "5 Promis / day free — Plus = unlimited",
                    "2 Nuées free — Plus = unlimited",
                    "€2.99 / month or €19.99 / year"
                ],
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
                // Markdown supporté : *mot* → italique (ex. "Thématique"
                // et "Intime" dans la slide Nuées).
                Text(attributedBody)
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

    // MARK: Body with Markdown support (*italic*)

    /// Parse le body comme Markdown pour supporter les italiques via *mot*.
    /// Fallback silencieux sur la string brute si le Markdown est invalide.
    private var attributedBody: AttributedString {
        (try? AttributedString(markdown: slide.body)) ?? AttributedString(slide.body)
    }

    // MARK: Title with Promi orange accent

    private var titleText: Text {
        var attributed = AttributedString(slide.title)
        attributed.font = .system(size: 26, weight: .light)
        attributed.foregroundColor = Color.white.opacity(0.94)

        // Highlight "Promi" in Brand.orange wherever it appears in the title.
        if let range = attributed.range(of: "Promi") {
            attributed[range].foregroundColor = Brand.orange
        }

        return Text(attributed)
    }

    // MARK: Examples list

    private var examplesList: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(slide.examples, id: \.self) { example in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(Brand.orange.opacity(0.58))
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
        case .social:
            // 4 étapes du contrat social Promi, de gauche à droite :
            // envoyer → recevoir → tenir → bravo. Même langage visuel
            // que les autres slides (formes géométriques en aplat).
            HStack(spacing: 10) {
                // 1. Envoyer (orange = action)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.08).opacity(0.92))
                    .frame(width: 44, height: 52)
                    .overlay(
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.92))
                    )
                // 2. Recevoir (bleu = l'autre)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.14, green: 0.46, blue: 0.96).opacity(0.92))
                    .frame(width: 44, height: 52)
                    .overlay(
                        Image(systemName: "tray.and.arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.92))
                    )
                // 3. Tenir (vert = accompli)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.75, blue: 0.48).opacity(0.92))
                    .frame(width: 44, height: 52)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.92))
                    )
                // 4. Bravo (noir = karma)
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "hands.clap")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.92))
                    )
            }

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

        case .nuées:
            // Même langage visuel que les autres slides : carrés arrondis
            // en aplat, composition qui évoque le sujet sans le sur-expliquer.
            // Violet = cercle intime (famille, amis proches). Émeraude =
            // cercle thématique ouvert. Cercle noir ambre au centre = le
            // Promi qui circule entre les cercles.
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.48, green: 0.34, blue: 0.78).opacity(0.92))
                    .frame(width: 102, height: 120)
                    .offset(x: -28, y: -6)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.24, green: 0.64, blue: 0.48).opacity(0.92))
                    .frame(width: 96, height: 84)
                    .offset(x: 28, y: 30)
                Circle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 64, height: 64)
            }
        }
    }
}
