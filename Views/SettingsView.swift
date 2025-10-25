//
//  SettingsView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        NavigationView {
            List {
                Section("Langue") {
                    HStack {
                        Text("Langue actuelle")
                        Spacer()
                        Text(userStore.getLanguageName())
                            .foregroundColor(Brand.textSecondary)
                    }
                }
                
                Section("Apparence") {
                    HStack {
                        Text("Palette actuelle")
                        Spacer()
                        Text(userStore.selectedPalette.displayName)
                            .foregroundColor(Brand.textSecondary)
                    }
                }
                
                Section("Tutoriel") {
                    Button(action: {
                        userStore.resetTutorial()
                        Haptics.shared.success()
                        dismiss()
                    }) {
                        HStack {
                            Text("Revoir le tutoriel")
                                .foregroundColor(Brand.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Brand.orange)
                        }
                    }
                }
                
                Section("Compte") {
                    HStack {
                        Text("ID Utilisateur")
                        Spacer()
                        Text(String(userStore.localUserId.prefix(8)))
                            .font(Typography.caption)
                            .foregroundColor(Brand.textSecondary)
                    }
                }
                
                Section("À propos") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(Brand.textSecondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2025.10.25")
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
                    .foregroundColor(Brand.orange)
                }
            }
        }
    }
}
