//
//  LanguageSelectionView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var navigateToOnboarding = false
    @State private var selectedLanguage: String? = nil
    @State private var showEasterEgg = false
    
    private let languages = LocalizationManager.shared.availableLanguages
    
    var body: some View {
        if navigateToOnboarding {
            OnboardingView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    Spacer()
                    
                    // Logo miniature
                    Image("LogoPromi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, Spacing.sm)
                    
                    // Titre
                    Text(LocalizationManager.shared.getLocalizedString("language.title", language: selectedLanguage ?? "en"))
                        .font(Typography.title2)
                        .foregroundColor(Brand.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    // Sous-titre
                    Text(LocalizationManager.shared.getLocalizedString("language.subtitle", language: selectedLanguage ?? "en"))
                        .font(Typography.callout)
                        .foregroundColor(Brand.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                    
                    // Liste des langues (scrollable)
                    ScrollView {
                        VStack(spacing: Spacing.sm) {
                            // Langues principales
                            ForEach(languages.filter { !$0.code.contains("-") || $0.code == "de-AT" }, id: \.code) { lang in
                                LanguageButton(
                                    emoji: lang.emoji,
                                    name: lang.name,
                                    isSelected: selectedLanguage == lang.code
                                ) {
                                    selectLanguage(lang.code)
                                }
                            }
                            
                            // Divider subtil
                            if !showEasterEgg {
                                Button(action: {
                                    withAnimation(AnimationPreset.spring) {
                                        showEasterEgg = true
                                    }
                                    Haptics.shared.lightTap()
                                }) {
                                    HStack {
                                        Text("···")
                                            .font(Typography.body)
                                            .foregroundColor(Brand.textSecondary)
                                        Text("Dialectes & easter eggs")
                                            .font(Typography.caption)
                                            .foregroundColor(Brand.textSecondary)
                                        Text("···")
                                            .font(Typography.body)
                                            .foregroundColor(Brand.textSecondary)
                                    }
                                    .padding(.vertical, Spacing.sm)
                                }
                            }
                            
                            // Dialectes (easter eggs)
                            if showEasterEgg {
                                ForEach(languages.filter { $0.code.contains("-") && $0.code != "de-AT" }, id: \.code) { lang in
                                    LanguageButton(
                                        emoji: lang.emoji,
                                        name: lang.name,
                                        isSelected: selectedLanguage == lang.code
                                    ) {
                                        selectLanguage(lang.code)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                    .frame(maxHeight: 400)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func selectLanguage(_ code: String) {
        selectedLanguage = code
        userStore.setLanguage(code)
        Haptics.shared.success()
        
        withAnimation(AnimationPreset.spring.delay(0.3)) {
            navigateToOnboarding = true
        }
    }
}

// MARK: - Language Button Component
struct LanguageButton: View {
    let emoji: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(AnimationPreset.springBouncy) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AnimationPreset.spring) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: Spacing.md) {
                Text(emoji)
                    .font(.system(size: 32))
                
                Text(name)
                    .font(Typography.body)
                    .foregroundColor(Brand.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Brand.orange)
                        .font(.system(size: 20))
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(isSelected ? Brand.orange.opacity(0.1) : Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
    }
}
