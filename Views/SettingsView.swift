//
//  SettingsView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        NavigationView {
            List {
                Section("Langue") {
                    Picker("Langue", selection: $userStore.selectedLanguage) {
                        Text("🇫🇷 Français").tag("fr")
                        Text("🇬🇧 English").tag("en")
                        Text("🇪🇸 Español").tag("es")
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Apparence") {
                    Button("Changer de palette") {
                        // Navigation handled by parent
                    }
                }
                
                Section("À propos") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(Brand.textSecondary)
                    }
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}
