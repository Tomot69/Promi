import SwiftUI

@main
struct PromiApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var promiStore = PromiStore()
    @StateObject private var karmaStore = KarmaStore()
    @StateObject private var draftStore = DraftStore()

    @State private var isShowingSplash = true

    var body: some Scene {
        WindowGroup {
            rootView
                .environmentObject(userStore)
                .environmentObject(promiStore)
                .environmentObject(karmaStore)
                .environmentObject(draftStore)
                .onAppear {
                    ReadPathBootstrapper.applyIfEnabled(
                        defaults: .standard,
                        promiStore: promiStore,
                        draftStore: draftStore
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
        } else if !userStore.hasCompletedOnboarding {
            OnboardingView()
        } else {
            ContentView()
        }
    }
}
