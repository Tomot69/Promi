import Foundation
import Combine

/// Central store for user identity, preferences and app-lifecycle flags.
///
/// Architectural note: visual identity (pack / mood) is **not** stored here —
/// it lives in SwiftUI `@AppStorage("promi.visualPack")` and
/// `@AppStorage("promi.visualMood")` bindings because they need to update
/// reactively across independent view hierarchies (home, Studio, chrome
/// pages). Keeping them in UserStore would require manual observer wiring
/// that `@AppStorage` already solves. The legacy `ColorPalette` system that
/// used to live here has been fully removed: it was an earlier beige-based
/// theme layer that the mood system has superseded.
final class UserStore: ObservableObject {
    @Published var localUserId: String
    @Published var selectedLanguage: String
    @Published var hasChosenLanguage: Bool
    @Published var hasCompletedOnboarding: Bool
    @Published var hasCompletedTutorial: Bool
    @Published var isPremium: Bool

    private let userDefaults = UserDefaults.standard

    private let userIdKey = "localUserId"
    private let languageKey = "selectedLanguage"
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
        self.hasChosenLanguage = userDefaults.bool(forKey: languageChosenKey)
        self.hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
        self.hasCompletedTutorial = userDefaults.bool(forKey: tutorialKey)
        self.isPremium = userDefaults.bool(forKey: premiumKey)
    }

    // MARK: - Language

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

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
    }

    /// Resets the onboarding flag so the user can replay it from Settings.
    /// Keeps the language choice and user id intact — only the onboarding
    /// slides are reset. This is the canonical way to re-trigger the
    /// onboarding flow from inside the app.
    func replayOnboarding() {
        hasCompletedOnboarding = false
        userDefaults.set(false, forKey: onboardingKey)
    }

    // MARK: - Tutorial

    func completeTutorial() {
        hasCompletedTutorial = true
        userDefaults.set(true, forKey: tutorialKey)
    }

    // MARK: - Premium

    func setPremium(_ isPremium: Bool) {
        self.isPremium = isPremium
        userDefaults.set(isPremium, forKey: premiumKey)
    }

    // MARK: - Debug

    /// Debug-only: resets both the language selection and the onboarding
    /// flags so the app enters its first-run flow from the beginning.
    /// Not available in release builds to prevent accidental wipes.
    #if DEBUG
    func resetEntryFlowForDebug() {
        hasChosenLanguage = false
        hasCompletedOnboarding = false
        userDefaults.set(false, forKey: languageChosenKey)
        userDefaults.set(false, forKey: onboardingKey)
    }
    #endif
}
