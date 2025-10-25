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
    @State private var previewBackground: Color
    
    init() {
        let current = Palette.promi
        _selectedPalette = State(initialValue: current)
        _previewBackground = State(initialValue: current.backgroundColor)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background dynamique (CORRECTION DU BUG)
                previewBackground
                    .ignoresSafeArea()
                    .animation(AnimationPreset.easeOut, value: previewBackground)
                
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: Spacing.md),
                            GridItem(.flexible(), spacing: Spacing.md)
                        ],
                        spacing: Spacing.lg
                    ) {
                        ForEach(Palette.allCases) { palette in
                            PaletteBubble(
                                palette: palette,
                                isSelected: selectedPalette == palette,
                                isUnlocked: isPaletteUnlocked(palette),
                                textColor: selectedPalette.textPrimaryColor
                            ) {
                                if isPaletteUnlocked(palette) {
                                    selectPalettePreview(palette)
                                } else {
                                    showUnlockAlert(palette)
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
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(selectedPalette.textSecondaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyPalette()
                    }
                    .foregroundColor(selectedPalette.accentColor)
                }
            }
            .onAppear {
                selectedPalette = userStore.selectedPalette
                previewBackground = userStore.selectedPalette.backgroundColor
            }
        }
    }
    
    private func selectPalettePreview(_ palette: Palette) {
        selectedPalette = palette
        
        withAnimation(AnimationPreset.easeOut) {
            previewBackground = palette.backgroundColor
        }
        
        Haptics.shared.lightTap()
    }
    
    private func applyPalette() {
        userStore.setPalette(selectedPalette)
        Haptics.shared.success()
        dismiss()
    }
    
    private func isPaletteUnlocked(_ palette: Palette) -> Bool {
        switch palette.unlockRequirement {
        case .free:
            return true
        case .karma(let required):
            return karmaStore.karmaState.percentage >= required
        case .purchase:
            return false // Mock: toujours verrouillé en V1
        case .secret(let karma, _):
            return karmaStore.karmaState.percentage >= karma && karmaStore.karmaState.earnedBadges.contains(.shibuiUnlocked)
        }
    }
    
    private func showUnlockAlert(_ palette: Palette) {
        Haptics.shared.lightTap()
        // Future: afficher une alert avec les conditions de déverrouillage
    }
}

// MARK: - Palette Bubble Component (MISE À JOUR)
struct PaletteBubble: View {
    let palette: Palette
    let isSelected: Bool
    let isUnlocked: Bool
    let textColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(AnimationPreset.springBouncy) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AnimationPreset.spring) {
                    isPressed = false
                }
            }
            action()
        }) {
            VStack(spacing: Spacing.sm) {
                // Cercle de couleur
                Circle()
                    .fill(palette.accentColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? palette.accentColor : Color.clear, lineWidth: 4)
                            .scaleEffect(1.2)
                    )
                    .blur(radius: isUnlocked ? 0 : 8)
                    .overlay(
                        Group {
                            if !isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                    )
                
                // Nom de la palette
                Text(palette.displayName)
                    .font(Typography.caption)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
                
                // Badge de déverrouillage
                if !isUnlocked {
                    Text(getUnlockText(palette))
                        .font(Typography.caption2)
                        .foregroundColor(textColor.opacity(0.6))
                }
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.white.opacity(isSelected ? 0.3 : 0.1))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(!isUnlocked)
    }
    
    private func getUnlockText(_ palette: Palette) -> String {
        switch palette.unlockRequirement {
        case .karma(let amount):
            return "\(amount) Karma"
        case .purchase(let price, _):
            return price
        case .secret:
            return "Secret"
        default:
            return ""
        }
    }
}
