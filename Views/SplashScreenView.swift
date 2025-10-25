//
//  SplashScreenView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var navigateToNext = false
    
    var body: some View {
        if navigateToNext {
            if userStore.hasCompletedOnboarding {
                ContentView()
            } else {
                LanguageSelectionView()
            }
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                Image("LogoPromi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
            }
            .onAppear {
                withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(Animation.easeOut(duration: 0.3)) {
                        navigateToNext = true
                    }
                }
            }
        }
    }
}
