import Foundation
import Combine

final class UserStore: ObservableObject {
    @Published var localUserId: String
    @Published var selectedLanguage: String
    @Published var selectedPalette: ColorPalette
    @Published var hasChosenLanguage: Bool
    @Published var hasCompletedOnboarding: Bool
    @Published var hasCompletedTutorial: Bool
    @Published var isPremium: Bool

    private let userDefaults = UserDefaults.standard

    private let userIdKey = "localUserId"
    private let languageKey = "selectedLanguage"
    private let paletteKey = "selectedPalette"
    private let languageChosenKey = "hasChosenLanguage"
    private let onboardingKey = "hasCompletedOnboarding"
    private let tutorialKey = "hasCompletedTutorial"
    private let premiumKey = "isPremium"

    init() {
        if let savedUserId = userDefaults.string(forKey: userIdKey) {
            self.localUserId = savedUserId
        } else {
            let newUserId = UUID().uuidString
            userDefaults.set(newUserId, forKey: userIdKey)
            self.localUserId = newUserId
        }

        self.selectedLanguage = userDefaults.string(forKey: languageKey) ?? "fr"

        if let paletteRawValue = userDefaults.string(forKey: paletteKey),
           let palette = ColorPalette(rawValue: paletteRawValue) {
            self.selectedPalette = palette
        } else {
            self.selectedPalette = .pureWhite
        }

        self.hasChosenLanguage = userDefaults.bool(forKey: languageChosenKey)
        self.hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
        self.hasCompletedTutorial = userDefaults.bool(forKey: tutorialKey)
        self.isPremium = userDefaults.bool(forKey: premiumKey)
    }

    func chooseLanguage(_ language: String) {
        selectedLanguage = language
        hasChosenLanguage = true
        userDefaults.set(language, forKey: languageKey)
        userDefaults.set(true, forKey: languageChosenKey)
    }

    func updateLanguage(_ language: String) {
        selectedLanguage = language
        userDefaults.set(language, forKey: languageKey)
    }

    func updatePalette(_ palette: ColorPalette) {
        selectedPalette = palette
        userDefaults.set(palette.rawValue, forKey: paletteKey)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
    }

    /// Resets the onboarding flag so the user can replay it from Settings.
    /// Keeps the language choice intact — only the onboarding slides are reset.
    func replayOnboarding() {
        hasCompletedOnboarding = false
        userDefaults.set(false, forKey: onboardingKey)
    }

    func completeTutorial() {
        hasCompletedTutorial = true
        userDefaults.set(true, forKey: tutorialKey)
    }

    func setPremium(_ isPremium: Bool) {
        self.isPremium = isPremium
        userDefaults.set(isPremium, forKey: premiumKey)
    }

    func resetEntryFlowForDebug() {
        hasChosenLanguage = false
        hasCompletedOnboarding = false
        userDefaults.set(false, forKey: languageChosenKey)
        userDefaults.set(false, forKey: onboardingKey)
    }
}
