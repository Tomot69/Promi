//
//  PaletteView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct PaletteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var karmaStore: KarmaStore
    
    @State private var selectedPalette: Palette
    
    init() {
        _selectedPalette = State(initialValue: .promi)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                selectedPalette.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.lg) {
                        ForEach(Palette.allCases) { palette in
                            PaletteBubble(
                                palette: palette,
                                isSelected: selectedPalette == palette,
                                isUnlocked: isPaletteUnlocked(palette)
                            ) {
                                if isPaletteUnlocked(palette) {
                                    selectedPalette = palette
                                    Haptics.shared.lightTap()
                                }
                            }
                        }
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("Pick Promi vibe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        userStore.setPalette(selectedPalette)
                        Haptics.shared.success()
                        dismiss()
                    }
                    .foregroundColor(Brand.orange)
                }
            }
            .onAppear {
                selectedPalette = userStore.selectedPalette
            }
        }
    }
    
    private func isPaletteUnlocked(_ palette: Palette) -> Bool {
        switch palette.unlockRequirement {
        case .free:
            return true
        case .karma(let required):
            return karmaStore.karmaState.percentage >= required
        case .purchase:
            return false // Mock: toujours verrouillé en V1
        case .secret(let karma, let badge):
            return karmaStore.karmaState.percentage >= karma && karmaStore.karmaState.earnedBadges.contains(.shibuiUnlocked)
        }
    }
}

struct PaletteBubble: View {
    let palette: Palette
    let isSelected: Bool
    let isUnlocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Circle()
                    .fill(palette.accentColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Brand.orange : Color.clear, lineWidth: 3)
                    )
                    .blur(radius: isUnlocked ? 0 : 8)
                
                Text(palette.displayName)
                    .font(Typography.callout)
                    .foregroundColor(Brand.textPrimary)
                
                if !isUnlocked {
                    Text("🔒")
                        .font(.system(size: 20))
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(Color.white.opacity(0.5))
            )
        }
        .disabled(!isUnlocked)
    }
}
