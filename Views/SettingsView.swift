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
    
    @State private var showLanguagePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                userStore.selectedPalette.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Réglages")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.9))
                        }
                        .padding(.top, 24)
                        
                        // Settings list
                        VStack(spacing: 24) {
                            // Language
                            Button(action: { showLanguagePicker = true }) {
                                SettingsRow(
                                    icon: "globe",
                                    label: "Langue",
                                    value: userStore.selectedLanguage.uppercased()
                                )
                            }
                            
                            // Premium
                            Button(action: {}) {
                                SettingsRow(
                                    icon: "star",
                                    label: "Premium",
                                    value: "Bientôt"
                                )
                            }
                            .disabled(true)
                            .opacity(0.4)
                            
                            // Notifications
                            Button(action: {}) {
                                SettingsRow(
                                    icon: "bell",
                                    label: "Notifications",
                                    value: "Bientôt"
                                )
                            }
                            .disabled(true)
                            .opacity(0.4)
                            
                            // About
                            Button(action: {}) {
                                SettingsRow(
                                    icon: "info.circle",
                                    label: "À propos",
                                    value: "v1.0"
                                )
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(Brand.orange.opacity(0.85))
                    .font(.system(size: 15, weight: .regular))
                }
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguageSelectionView()
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    @EnvironmentObject var userStore: UserStore
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .ultraLight))
                .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(userStore.selectedPalette.textSecondaryColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.06), lineWidth: 0.2)
        )
    }
}
