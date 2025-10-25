//
//  LanguageSelectionView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedLanguage = "fr"
    @State private var navigateToOnboarding = false
    
    private let languages = [
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
                
                VStack(spacing: 48) {
                    Spacer()
                    
                    // Logo
                    Image("LogoPromi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("Promi")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundColor(Brand.orange)
                        
                        Text("Choisis ta langue")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Brand.textSecondary)
                    }
                    
                    // Language buttons
                    VStack(spacing: 16) {
                        ForEach(languages, id: \.0) { code, name, flag in
                            Button(action: {
                                selectedLanguage = code
                                Haptics.shared.lightTap()
                            }) {
                                HStack(spacing: 16) {
                                    Text(flag)
                                        .font(.system(size: 32))
                                    
                                    Text(name)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Brand.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedLanguage == code {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(Brand.orange)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(
                                            selectedLanguage == code
                                            ? Brand.orange.opacity(0.4)
                                            : Brand.textPrimary.opacity(0.1),
                                            lineWidth: selectedLanguage == code ? 0.8 : 0.3
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: {
                        userStore.updateLanguage(selectedLanguage)
                        Haptics.shared.success()
                        withAnimation(Animation.easeOut(duration: 0.3)) {
                            navigateToOnboarding = true
                        }
                    }) {
                        Text("Continuer")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Brand.orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Brand.orange.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
        }
    }
}
