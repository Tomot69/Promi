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
                    // Header avec Skip
                    HStack {
                        Spacer()
                        
                        Button(action: skipToLast) {
                            Text("Skip")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Brand.textSecondary.opacity(0.5))
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 24)
                    }
                    
                    // Slides
                    TabView(selection: $currentPage) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            MinimalOnboardingSlideView(slide: slides[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Brand.textPrimary.opacity(0.6) : Brand.textPrimary.opacity(0.15))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 16)
                    
                    // Bottom Button
                    Button(action: handleNextButton) {
                        Text(getButtonText())
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Brand.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Brand.textPrimary.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    private func skipToLast() {
        Haptics.shared.lightTap()
        withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
            currentPage = slides.count - 1
        }
    }
    
    private func handleNextButton() {
        Haptics.shared.lightTap()
        
        if currentPage < slides.count - 1 {
            withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
                currentPage += 1
            }
        } else {
            withAnimation(Animation.easeOut(duration: 0.3)) {
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
        withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
            navigateToHome = true
        }
    }
}

// MARK: - Minimal Onboarding Slide View
struct MinimalOnboardingSlideView: View {
    let slide: OnboardingSlideData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
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
                .padding(.bottom, 16)
                
                // Title
                Text(slide.title)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Brand.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Body
                Text(slide.body)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Brand.textSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
                
                // Examples
                if let examples = slide.examples {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(examples, id: \.self) { example in
                            Text(example)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Brand.textSecondary.opacity(0.5))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
