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
    
    let languages = [
        ("fr", "Français", "🇫🇷"),
        ("en", "English", "🇬🇧"),
        ("es", "Español", "🇪🇸")
    ]
    
    var body: some View {
        if navigateToOnboarding {
            OnboardingView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    Spacer()
                    
                    Text("Choose your language")
                        .font(Typography.title2)
                        .foregroundColor(Brand.textPrimary)
                    
                    Text("Choisissez votre langue")
                        .font(Typography.callout)
                        .foregroundColor(Brand.textSecondary)
                    
                    VStack(spacing: Spacing.md) {
                        ForEach(languages, id: \.0) { code, name, flag in
                            Button(action: {
                                userStore.setLanguage(code)
                                Haptics.shared.lightTap()
                                withAnimation(AnimationPreset.spring) {
                                    navigateToOnboarding = true
                                }
                            }) {
                                HStack {
                                    Text(flag)
                                        .font(.system(size: 32))
                                    
                                    Text(name)
                                        .font(Typography.body)
                                        .foregroundColor(Brand.textPrimary)
                                    
                                    Spacer()
                                }
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    
                    Spacer()
                }
            }
        }
    }
}
