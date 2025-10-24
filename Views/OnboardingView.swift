//
//  OnboardingView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var currentPage = 0
    @State private var navigateToHome = false
    
    let slides = [
        OnboardingSlide(
            emoji: "🤝",
            title: "Les petites promesses",
            body: "Engagements simples, datés, tenus. C'est tout."
        ),
        OnboardingSlide(
            emoji: "📅",
            title: "Crée ton Promi",
            body: "Titre, date, importance. Pas de bruit."
        ),
        OnboardingSlide(
            emoji: "❤️",
            title: "Jauge d'intensité",
            body: "Révèle le cœur en deux coups de pinceau."
        ),
        OnboardingSlide(
            emoji: "🏆",
            title: "Ton Karma grandit",
            body: "Tiens tes promesses, débloque des palettes."
        ),
        OnboardingSlide(
            emoji: "🎨",
            title: "Pick Promi vibe",
            body: "Change d'ambiance, reste fidèle."
        )
    ]
    
    var body: some View {
        if navigateToHome {
            ContentView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(Typography.callout)
                        .foregroundColor(Brand.textSecondary)
                        .padding(.trailing, Spacing.lg)
                    }
                    .padding(.top, Spacing.lg)
                    
                    TabView(selection: $currentPage) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            VStack(spacing: Spacing.xl) {
                                Spacer()
                                
                                Text(slides[index].emoji)
                                    .font(.system(size: 80))
                                
                                Text(slides[index].title)
                                    .font(Typography.title2)
                                    .foregroundColor(Brand.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text(slides[index].body)
                                    .font(Typography.body)
                                    .foregroundColor(Brand.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, Spacing.xl)
                                
                                Spacer()
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    
                    Button(action: {
                        if currentPage < slides.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage < slides.count - 1 ? "Suivant" : "Commencer")
                            .font(Typography.bodyEmphasis)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(Brand.orange)
                            .cornerRadius(CornerRadius.sm)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
    }
    
    private func completeOnboarding() {
        userStore.completeOnboarding()
        Haptics.shared.success()
        withAnimation(AnimationPreset.spring) {
            navigateToHome = true
        }
    }
}

struct OnboardingSlide {
    let emoji: String
    let title: String
    let body: String
}
