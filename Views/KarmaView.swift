//
//  KarmaView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct KarmaView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var karmaStore: KarmaStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        NavigationView {
            ZStack {
                userStore.selectedPalette.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Text("Karma")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.9))
                            
                            Text("\(karmaStore.karmaState.percentage)%")
                                .font(.system(size: 72, weight: .ultraLight))
                                .foregroundColor(karmaColor)
                        }
                        .padding(.top, 32)
                        
                        Text(karmaStore.getRoast(language: userStore.selectedLanguage))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        VStack(spacing: 24) {
                            KarmaStatRow(
                                label: "Total",
                                value: "\(karmaStore.karmaState.totalPromis)",
                                color: userStore.selectedPalette.textPrimaryColor
                            )
                            
                            KarmaStatRow(
                                label: "Tenus",
                                value: "\(karmaStore.karmaState.completedPromis)",
                                color: Brand.karmaGood
                            )
                            
                            KarmaStatRow(
                                label: "Ratés",
                                value: "\(karmaStore.karmaState.failedPromis)",
                                color: Brand.karmaPoor
                            )
                            
                            KarmaStatRow(
                                label: "En cours",
                                value: "\(karmaStore.karmaState.pendingPromis)",
                                color: Brand.karmaAverage
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 24)
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
    }
    
    private var karmaColor: Color {
        let karma = karmaStore.karmaState.percentage
        if karma >= 90 { return Brand.karmaExcellent }
        else if karma >= 70 { return Brand.karmaGood }
        else if karma >= 50 { return Brand.karmaAverage }
        else { return Brand.karmaPoor }
    }
}

// MARK: - Karma Stat Row
struct KarmaStatRow: View {
    @EnvironmentObject var userStore: UserStore
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(userStore.selectedPalette.textSecondaryColor)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.06), lineWidth: 0.2)
        )
    }
}
