//
//  OnboardingView.swift
//  Promi
//
//  Created on 25/10/2025.
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
                    // Header avec Skip (ultra-discret)
                    HStack {
                        Spacer()
                        
                        Button(action: skipToLast) {
                            Text("Skip")
                                .font(Typography.caption)
                                .foregroundColor(Brand.textSecondary.opacity(0.5))
                        }
                        .padding(.trailing, Spacing.xl)
                        .padding(.top, Spacing.xl)
                    }
                    
                    // Slides
                    TabView(selection: $currentPage) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            MinimalOnboardingSlideView(slide: slides[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom page indicators (ultra-minimalistes)
                    HStack(spacing: Spacing.xs) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Brand.textPrimary.opacity(0.6) : Brand.textPrimary.opacity(0.15))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, Spacing.md)
                    
                    // Bottom Button (ultra-minimal)
                    Button(action: handleNextButton) {
                        Text(getButtonText())
                            .font(Typography.callout)
                            .foregroundColor(Brand.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.xs)
                                    .stroke(Brand.textPrimary.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                }
            }
        }
    }
    
    private func skipToLast() {
        Haptics.shared.lightTap()
        withAnimation(AnimationPreset.spring) {
            currentPage = slides.count - 1
        }
    }
    
    private func handleNextButton() {
        Haptics.shared.lightTap()
        
        if currentPage < slides.count - 1 {
            withAnimation(AnimationPreset.spring) {
                currentPage += 1
            }
        } else {
            withAnimation(AnimationPreset.easeOut) {
                showPinkyAnimation = true
            }
        }
    }
    
    private func getButtonText() -> String {
        if currentPage < slides.count - 1 {
            return userStore.selectedLanguage.starts(with: "en") ? "Next" : "Suivant"
        } else {
            return userStore.selectedLanguage.starts(with: "en") ? "Let's start" : "C'est parti"
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

// MARK: - Minimal Onboarding Slide View
struct MinimalOnboardingSlideView: View {
    let slide: OnboardingSlideData
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Icon (ultra-minimal)
                Group {
                    switch slide.type {
                    case .concept:
                        Image("LogoPromi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    case .karma:
                        Text("🏆")
                            .font(.system(size: 60))
                    case .premium:
                        Text("✨")
                            .font(.system(size: 60))
                    case .account:
                        Text("🤝")
                            .font(.system(size: 60))
                    }
                }
                .padding(.bottom, Spacing.lg)
                
                // Title
                Text(slide.title)
                    .font(Typography.title3)
                    .foregroundColor(Brand.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxl)
                
                // Body
                Text(slide.body)
                    .font(Typography.callout)
                    .foregroundColor(Brand.textSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxl)
                    .lineSpacing(4)
                
                // Examples (ultra-épurés)
                if let examples = slide.examples {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ForEach(examples, id: \.self) { example in
                            Text(example)
                                .font(Typography.caption)
                                .foregroundColor(Brand.textSecondary.opacity(0.5))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.top, Spacing.md)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
