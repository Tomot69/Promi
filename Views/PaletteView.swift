//
//  PaletteView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct PaletteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                userStore.selectedPalette.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Palettes")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.9))
                            
                            Text("Choisis ton ambiance")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor)
                        }
                        .padding(.top, 24)
                        
                        // Grid de palettes
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(ColorPalette.allCases, id: \.self) { palette in
                                PaletteCardView(
                                    palette: palette,
                                    isSelected: userStore.selectedPalette == palette
                                )
                                .onTapGesture {
                                    withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
                                        userStore.selectedPalette = palette
                                    }
                                    Haptics.shared.tinyPop()
                                }
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
    }
}

// MARK: - Palette Card
struct PaletteCardView: View {
    let palette: ColorPalette
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Échantillon de couleur
            ZStack {
                Circle()
                    .fill(palette.backgroundColor)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(palette.textPrimaryColor.opacity(0.1), lineWidth: 0.5)
                    .frame(width: 80, height: 80)
                
                // Checkmark si sélectionné
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundColor(Brand.orange.opacity(0.9))
                }
            }
            
            // Nom
            Text(palette.name)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(palette.textPrimaryColor.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(palette.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            isSelected
                            ? Brand.orange.opacity(0.4)
                            : palette.textPrimaryColor.opacity(0.08),
                            lineWidth: isSelected ? 0.8 : 0.2
                        )
                )
        )
    }
}
