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

    // Identité Apple (optionnelle — l'utilisateur peut continuer sans).
    // `appleUserId` : l'identifiant stable fourni par Sign in with Apple,
    // valable pour toute la vie de l'app sur cet appareil/compte. Sert
    // de pont vers les futurs échanges CloudKit (quand Apple Dev payé).
    @Published var appleUserId: String?
    @Published var appleFullName: String?
    @Published var appleEmail: String?
    @Published var hasCompletedAppleSignIn: Bool

    // Nom d'utilisateur choisi par l'utilisateur, modifiable dans Settings.
    // Distinct de `appleFullName` (qui est le "vrai" nom Apple, souvent
    // incomplet/privacy-masqué). C'est ce nom qui apparaîtra dans les
    // Nuées/Promi partagés.
    @Published var username: String
    @Published var hasChosenUsername: Bool

    // Quota free tier — compteur de Promi créés aujourd'hui. Réinitialisé
    // chaque jour automatiquement au premier accès. La date de dernier
    // reset est stockée pour détecter le changement de jour.
    @Published var promisCreatedToday: Int
    @Published var lastQuotaResetDate: String  // "yyyy-MM-dd"

    // Acceptation des CGU + Politique de confidentialité.
    // `hasAcceptedTerms` : a déjà accepté au moins une fois.
    // `acceptedTermsVersion` : version des CGU acceptées. Si la version
    //   courante (LegalConstants.currentTermsVersion) est supérieure,
    //   on redemande l'acceptation au prochain lancement.
    @Published var hasAcceptedTerms: Bool
    @Published var acceptedTermsVersion: Int

    private let userDefaults = UserDefaults.standard

    private let userIdKey = "localUserId"
    private let languageKey = "selectedLanguage"
    private let languageChosenKey = "hasChosenLanguage"
    private let onboardingKey = "hasCompletedOnboarding"
    private let tutorialKey = "hasCompletedTutorial"
    private let premiumKey = "isPremium"
    private let appleUserIdKey = "appleUserId"
    private let appleFullNameKey = "appleFullName"
    private let appleEmailKey = "appleEmail"
    private let hasCompletedAppleSignInKey = "hasCompletedAppleSignIn"
    private let usernameKey = "username"
    private let hasChosenUsernameKey = "hasChosenUsername"
    private let hasAcceptedTermsKey = "hasAcceptedTerms"
    private let acceptedTermsVersionKey = "acceptedTermsVersion"
    private let promisCreatedTodayKey = "promisCreatedToday"
    private let lastQuotaResetDateKey = "lastQuotaResetDate"

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
        self.appleUserId = userDefaults.string(forKey: appleUserIdKey)
        self.appleFullName = userDefaults.string(forKey: appleFullNameKey)
        self.appleEmail = userDefaults.string(forKey: appleEmailKey)
        self.hasCompletedAppleSignIn = userDefaults.bool(forKey: hasCompletedAppleSignInKey)
        self.username = userDefaults.string(forKey: usernameKey) ?? ""
        self.hasChosenUsername = userDefaults.bool(forKey: hasChosenUsernameKey)
        self.hasAcceptedTerms = userDefaults.bool(forKey: hasAcceptedTermsKey)
        self.acceptedTermsVersion = userDefaults.integer(forKey: acceptedTermsVersionKey)

        // Quota : compteur de Promi par jour.
        let savedDate = userDefaults.string(forKey: lastQuotaResetDateKey) ?? ""
        let todayStr = Self.todayDateString()
        if savedDate == todayStr {
            self.promisCreatedToday = userDefaults.integer(forKey: promisCreatedTodayKey)
            self.lastQuotaResetDate = savedDate
        } else {
            // Nouveau jour → reset du compteur.
            self.promisCreatedToday = 0
            self.lastQuotaResetDate = todayStr
            userDefaults.set(0, forKey: promisCreatedTodayKey)
            userDefaults.set(todayStr, forKey: lastQuotaResetDateKey)
        }
    }

    // MARK: - Quota (free tier)

    /// True si l'utilisateur peut encore créer un Promi aujourd'hui
    /// (soit il est Premium, soit il n'a pas atteint le quota).
    var canCreatePromi: Bool {
        if isPremium { return true }
        resetQuotaIfNewDay()
        return promisCreatedToday < QuotaConstants.freePromiPerDay
    }

    /// Nombre de Promi restants aujourd'hui (free tier uniquement).
    var promisRemainingToday: Int {
        if isPremium { return .max }
        resetQuotaIfNewDay()
        return max(0, QuotaConstants.freePromiPerDay - promisCreatedToday)
    }

    /// True si l'utilisateur peut encore créer une Nuée top-level
    /// (soit Premium, soit en dessous du quota total).
    func canCreateNuée(currentTopLevelCount: Int) -> Bool {
        if isPremium { return true }
        return currentTopLevelCount < QuotaConstants.freeNuéesTotal
    }

    /// À appeler APRÈS chaque création réussie de Promi. Incrémente
    /// le compteur quotidien et persiste.
    func recordPromiCreation() {
        resetQuotaIfNewDay()
        promisCreatedToday += 1
        userDefaults.set(promisCreatedToday, forKey: promisCreatedTodayKey)
    }

    /// Reset automatique si on est passé à un nouveau jour calendaire.
    private func resetQuotaIfNewDay() {
        let today = Self.todayDateString()
        guard today != lastQuotaResetDate else { return }
        promisCreatedToday = 0
        lastQuotaResetDate = today
        userDefaults.set(0, forKey: promisCreatedTodayKey)
        userDefaults.set(today, forKey: lastQuotaResetDateKey)
    }

    private static func todayDateString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone = .current
        return fmt.string(from: Date())
    }

    // MARK: - Legal acceptance

    /// True si l'utilisateur doit (re)voir l'écran d'acceptation. Vrai
    /// soit s'il n'a jamais accepté, soit si la version a été incrémentée
    /// depuis sa dernière acceptation (modification substantielle des CGU).
    var mustShowTermsAcceptance: Bool {
        !hasAcceptedTerms || acceptedTermsVersion < LegalConstants.currentTermsVersion
    }

    func acceptCurrentTerms() {
        hasAcceptedTerms = true
        acceptedTermsVersion = LegalConstants.currentTermsVersion
        userDefaults.set(true, forKey: hasAcceptedTermsKey)
        userDefaults.set(LegalConstants.currentTermsVersion, forKey: acceptedTermsVersionKey)
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
    /// Also resets the tutorial flag so the 3 tutorial cards replay on the
    /// home screen after the onboarding slides — the full "first launch"
    /// experience is re-triggered as a unit. Keeps the language choice and
    /// user id intact.
    func replayOnboarding() {
        hasCompletedOnboarding = false
        hasCompletedTutorial = false
        userDefaults.set(false, forKey: onboardingKey)
        userDefaults.set(false, forKey: tutorialKey)
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

    // MARK: - Apple Sign In

    /// Stocke les informations renvoyées par Sign in with Apple. Le full
    /// name et l'email ne sont renvoyés QUE la première fois — donc on
    /// ne les écrase jamais par nil ensuite (préserve ce qu'on a).
    func saveAppleSignIn(userId: String, fullName: String?, email: String?) {
        self.appleUserId = userId
        userDefaults.set(userId, forKey: appleUserIdKey)
        if let fullName, !fullName.isEmpty {
            self.appleFullName = fullName
            userDefaults.set(fullName, forKey: appleFullNameKey)
        }
        if let email, !email.isEmpty {
            self.appleEmail = email
            userDefaults.set(email, forKey: appleEmailKey)
        }
        self.hasCompletedAppleSignIn = true
        userDefaults.set(true, forKey: hasCompletedAppleSignInKey)
    }

    /// L'utilisateur a explicitement choisi de continuer sans Apple ID.
    /// On marque le flag comme complété pour ne pas re-demander, mais
    /// on ne stocke pas d'identité Apple.
    func skipAppleSignIn() {
        self.hasCompletedAppleSignIn = true
        userDefaults.set(true, forKey: hasCompletedAppleSignInKey)
    }

    // MARK: - Username

    func setUsername(_ newUsername: String) {
        let trimmed = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        self.username = trimmed
        self.hasChosenUsername = true
        userDefaults.set(trimmed, forKey: usernameKey)
        userDefaults.set(true, forKey: hasChosenUsernameKey)
    }

    /// Nom à afficher dans les UI partagées. Priorité :
    /// username (choisi) > appleFullName (Apple) > "Vous"/"You" (fallback).
    var displayName: String {
        if !username.isEmpty { return username }
        if let appleFullName, !appleFullName.isEmpty { return appleFullName }
        return selectedLanguage.starts(with: "en") ? "You" : "Vous"
    }

    // MARK: - Debug

    /// Debug-only: resets both the language selection and the onboarding
    /// flags so the app enters its first-run flow from the beginning.
    /// Not available in release builds to prevent accidental wipes.
    #if DEBUG
    func resetEntryFlowForDebug() {
        hasChosenLanguage = false
        hasCompletedOnboarding = false
        hasCompletedAppleSignIn = false
        hasChosenUsername = false
        hasAcceptedTerms = false
        acceptedTermsVersion = 0
        userDefaults.set(false, forKey: languageChosenKey)
        userDefaults.set(false, forKey: onboardingKey)
        userDefaults.set(false, forKey: hasCompletedAppleSignInKey)
        userDefaults.set(false, forKey: hasChosenUsernameKey)
        userDefaults.set(false, forKey: hasAcceptedTermsKey)
        userDefaults.set(0, forKey: acceptedTermsVersionKey)
    }
    #endif
}
