//
//  PromiApp.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

@main
struct PromiApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var promiStore = PromiStore()
    @StateObject private var karmaStore = KarmaStore()
    @StateObject private var draftStore = DraftStore()

    var body: some Scene {
        WindowGroup {
            if userStore.hasCompletedOnboarding {
                ContentView()
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
                    }
            } else {
                SplashScreenView()
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
                    }
            }
        }
    }
}

