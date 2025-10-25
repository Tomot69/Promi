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
    @State private var showPinkyAnimation = false
    @State private var navigateToHome = false
    
    private var slides: [OnboardingSlideData] {
        OnboardingContent.getSlides(language: userStore.selectedLanguage)
    }
    
    var body: some View {
        if navigateToHome {
            ContentView()
        } else if showPinkyAnimation {
            PinkyPromiseAnimationView {
                completeOnboarding()
            }
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header avec Skip
                    HStack {
                        Spacer()
                        
                        Button(action: skipToPreview) {
                            Text("Skip")
                                .font(Typography.callout)
                                .foregroundColor(Brand.textSecondary)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        .padding(.trailing, Spacing.lg)
                        .padding(.top, Spacing.lg)
                    }
                    
                    // Slides
                    TabView(selection: $currentPage) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            OnboardingSlideView(slide: slides[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    // Bottom Button
                    Button(action: handleNextButton) {
                        Text(getButtonText())
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
    
    private func skipToPreview() {
        Haptics.shared.lightTap()
        withAnimation(AnimationPreset.spring) {
            currentPage = slides.count - 2 // Slide Premium
        }
    }
    
    private func handleNextButton() {
        Haptics.shared.lightTap()
        
        if currentPage < slides.count - 1 {
            withAnimation(AnimationPreset.spring) {
                currentPage += 1
            }
        } else {
            // Dernier slide (Account) → Animation Pinky Promise
            withAnimation(AnimationPreset.easeOut) {
                showPinkyAnimation = true
            }
        }
    }
    
    private func getButtonText() -> String {
        if currentPage < slides.count - 1 {
            return "Suivant"
        } else {
            return "Commencer"
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

// MARK: - Onboarding Slide View
struct OnboardingSlideView: View {
    let slide: OnboardingSlideData
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Icon
                Group {
                    switch slide.type {
                    case .concept:
                        Image("LogoPromi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    case .karma:
                        Text("🏆")
                            .font(.system(size: 80))
                    case .premium:
                        Text("✨")
                            .font(.system(size: 80))
                    case .account:
                        Text("🤝")
                            .font(.system(size: 80))
                    }
                }
                .padding(.bottom, Spacing.md)
                
                // Title
                Text(slide.title)
                    .font(Typography.title2)
                    .foregroundColor(Brand.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                
                // Body
                Text(slide.body)
                    .font(Typography.body)
                    .foregroundColor(Brand.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                
                // Examples (if any)
                if let examples = slide.examples {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ForEach(examples, id: \.self) { example in
                            HStack(alignment: .top, spacing: Spacing.xs) {
                                Text(example)
                                    .font(Typography.callout)
                                    .foregroundColor(Brand.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, Spacing.xl)
                        }
                    }
                    .padding(.top, Spacing.md)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Deprecated struct (kept for compatibility but unused)
struct OnboardingSlide {
    let useCustomIcon: Bool
    let emoji: String
    let title: String
    let body: String
}
