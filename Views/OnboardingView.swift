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
            useCustomIcon: true, // Utilise le logo
            emoji: "", // Pas d'emoji
            title: "Les petites promesses",
            body: "Engagements simples, datés, tenus. C'est tout."
        ),
        OnboardingSlide(
            useCustomIcon: false,
            emoji: "📅",
            title: "Crée ton Promi",
            body: "Titre, date, importance. Pas de bruit."
        ),
        OnboardingSlide(
            useCustomIcon: false,
            emoji: "❤️",
            title: "Jauge d'intensité",
            body: "Révèle le cœur en deux coups de pinceau."
        ),
        OnboardingSlide(
            useCustomIcon: false,
            emoji: "🏆",
            title: "Ton Karma grandit",
            body: "Tiens tes promesses, débloque des palettes."
        ),
        OnboardingSlide(
            useCustomIcon: false,
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
                                
                                // Affichage conditionnel : logo ou emoji
                                if slides[index].useCustomIcon {
                                    Image("LogoPromi")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                } else {
                                    Text(slides[index].emoji)
                                        .font(.system(size: 80))
                                }
                                
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
                            Haptics.shared.lightTap()
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
    let useCustomIcon: Bool
    let emoji: String
    let title: String
    let body: String
}
