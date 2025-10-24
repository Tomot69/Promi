//
//  PromiApp.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

@main
struct PromiApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var promiStore = PromiStore()
    @StateObject private var karmaStore = KarmaStore()
    
    var body: some Scene {
        WindowGroup {
            if userStore.hasCompletedOnboarding {
                ContentView()
                    .environmentObject(userStore)
                    .environmentObject(promiStore)
                    .environmentObject(karmaStore)
            } else {
                SplashScreenView()
                    .environmentObject(userStore)
                    .environmentObject(promiStore)
                    .environmentObject(karmaStore)
            }
        }
    }
}
