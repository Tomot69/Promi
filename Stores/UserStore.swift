//
//  UserStore.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation
import Combine

// MARK: - User Store
class UserStore: ObservableObject {
    @Published var localUserId: String
    @Published var selectedLanguage: String
    @Published var selectedPalette: ColorPalette
    @Published var hasCompletedOnboarding: Bool
    @Published var hasCompletedTutorial: Bool
    @Published var isPremium: Bool
    
    private let userDefaults = UserDefaults.standard
    
    private let userIdKey = "localUserId"
    private let languageKey = "selectedLanguage"
    private let paletteKey = "selectedPalette"
    private let onboardingKey = "hasCompletedOnboarding"
    private let tutorialKey = "hasCompletedTutorial"
    private let premiumKey = "isPremium"
    
    init() {
        // Load or generate user ID
        if let savedUserId = userDefaults.string(forKey: userIdKey) {
            self.localUserId = savedUserId
        } else {
            let newUserId = UUID().uuidString
            userDefaults.set(newUserId, forKey: userIdKey)
            self.localUserId = newUserId
        }
        
        // Load language
        self.selectedLanguage = userDefaults.string(forKey: languageKey) ?? "fr"
        
        // Load palette
        if let paletteRawValue = userDefaults.string(forKey: paletteKey),
           let palette = ColorPalette(rawValue: paletteRawValue) {
            self.selectedPalette = palette
        } else {
            self.selectedPalette = .pureWhite
        }
        
        // Load onboarding status
        self.hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
        
        // Load tutorial status
        self.hasCompletedTutorial = userDefaults.bool(forKey: tutorialKey)
        
        // Load premium status
        self.isPremium = userDefaults.bool(forKey: premiumKey)
    }
    
    func updateLanguage(_ language: String) {
        selectedLanguage = language
        userDefaults.set(language, forKey: languageKey)
        objectWillChange.send()
    }
    
    func updatePalette(_ palette: ColorPalette) {
        selectedPalette = palette
        userDefaults.set(palette.rawValue, forKey: paletteKey)
        objectWillChange.send()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
        objectWillChange.send()
    }
    
    func completeTutorial() {
        hasCompletedTutorial = true
        userDefaults.set(true, forKey: tutorialKey)
        objectWillChange.send()
    }
    
    func setPremium(_ isPremium: Bool) {
        self.isPremium = isPremium
        userDefaults.set(isPremium, forKey: premiumKey)
        objectWillChange.send()
    }
}
