import SwiftUI

@main
struct PromiApp: App {
    @UIApplicationDelegateAdaptor(PromiAppDelegate.self) var appDelegate
    @StateObject private var userStore = UserStore()
    @StateObject private var promiStore = PromiStore()
    @StateObject private var karmaStore = KarmaStore()
    @StateObject private var draftStore = DraftStore()
    @StateObject private var nuéeStore = NuéeStore()
    @StateObject private var contactsStore = ContactsStore()

    @State private var isShowingSplash = true
    @State private var canvasOpacity: Double = 0

    var body: some Scene {
        WindowGroup {
            rootView
                .background(ShakeDetectorView())
                .environmentObject(userStore)
                .environmentObject(promiStore)
                .environmentObject(karmaStore)
                .environmentObject(draftStore)
                .environmentObject(nuéeStore)
                .environmentObject(contactsStore)
                .onAppear {
                    ReadPathBootstrapper.applyIfEnabled(
                        defaults: .standard,
                        promiStore: promiStore,
                        draftStore: draftStore
                    )

                    // Reconcile local notifications for ephemeral Nuées.
                    let userNuées = nuéeStore.nuées(for: userStore.localUserId)
                    NuéeLifecycleManager.reconcileNotifications(for: userNuées)

                    // Notifications Promi : permission + reprogrammation.
                    // Première fois → activer par défaut.
                    if !UserDefaults.standard.bool(forKey: "promi.notificationsInitialized") {
                        UserDefaults.standard.set(true, forKey: "promi.notificationsEnabled")
                        UserDefaults.standard.set(true, forKey: "promi.notificationsInitialized")
                    }
                    NotificationManager.shared.requestPermission()
                    NotificationManager.shared.rescheduleAll(
                        promis: promiStore.promis,
                        language: userStore.selectedLanguage
                    )
                    NotificationManager.shared.updateBadge(promis: promiStore.promis)
                    karmaStore.validateStreak()
                    karmaStore.loadHistory()
                    NotificationManager.shared.scheduleMorningReminder(
                        promis: promiStore.promis,
                        language: userStore.selectedLanguage
                    )

                    guard isShowingSplash else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
                        withAnimation(.easeOut(duration: 0.28)) {
                            isShowingSplash = false
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        if isShowingSplash {
            SplashScreenView()
        } else if !userStore.hasChosenLanguage {
            LanguageSelectionView()
        } else if userStore.mustShowTermsAcceptance {
            // Étape légale obligatoire : acceptation des CGU et
            // Politique de confidentialité avant tout accès au reste
            // de l'app. Re-présenté automatiquement si la version
            // des CGU est incrémentée plus tard.
            TermsAcceptanceView()
        } else if !userStore.hasCompletedAppleSignIn {
            // Étape 4 du flow : Sign in with Apple (avant l'onboarding).
            // L'utilisateur peut se connecter ou passer en local-only.
            AppleSignInView()
        } else if !userStore.hasCompletedOnboarding {
            OnboardingView()
        } else if !userStore.hasChosenUsername {
            // Étape 5 : choix du nom d'utilisateur (après onboarding,
            // avant le tuto qui est déclenché depuis ContentView).
            UsernameSetupView()
        } else {
            ContentView()
        }
    }
}
class PromiAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    /// Affiche la notification même quand l'app est au premier plan.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Tap sur une notification → l'app s'ouvre (pas d'action custom pour l'instant,
    /// mais le framework est prêt pour ouvrir le Promi spécifique quand on ajoutera
    /// le promiId dans le userInfo de la notification).
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
