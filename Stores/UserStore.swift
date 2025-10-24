//
//  UserStore.swift
//  Promi
//
//  Created on 24/10/2025.
//

import Foundation
import Combine

// MARK: - User Store
class UserStore: ObservableObject {
    @Published var localUserId: String
    @Published var selectedLanguage: String
    @Published var selectedPalette: Palette
    @Published var hasCompletedOnboarding: Bool
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        // Local User ID (généré une seule fois)
        if let savedId = userDefaults.string(forKey: "localUserId") {
            self.localUserId = savedId
        } else {
            let newId = UUID().uuidString
            userDefaults.set(newId, forKey: "localUserId")
            self.localUserId = newId
        }
        
        // Langue
        self.selectedLanguage = userDefaults.string(forKey: "selectedLanguage") ?? "fr"
        
        // Palette
        let paletteRaw = userDefaults.string(forKey: "selectedPalette") ?? "promi"
        self.selectedPalette = Palette(rawValue: paletteRaw) ?? .promi
        
        // Onboarding
        self.hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
    }
    
    func setLanguage(_ language: String) {
        selectedLanguage = language
        userDefaults.set(language, forKey: "selectedLanguage")
    }
    
    func setPalette(_ palette: Palette) {
        selectedPalette = palette
        userDefaults.set(palette.rawValue, forKey: "selectedPalette")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
    }
}
