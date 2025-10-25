//
//  BottomIconsBar.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct BottomIconsBar: View {
    let textColor: Color
    let onDraftTap: () -> Void
    let onPaletteTap: () -> Void
    let onKarmaTap: () -> Void
    let onSettingsTap: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: Spacing.xxxl) {
                // Draft
                Button(action: {
                    Haptics.shared.lightTap()
                    onDraftTap()
                }) {
                    DraftIcon(color: textColor, orangeDot: true)
                        .frame(width: 32, height: 32)
                }
                
                // Palette
                Button(action: {
                    Haptics.shared.lightTap()
                    onPaletteTap()
                }) {
                    PaletteIcon(color: textColor, orangeDot: true)
                        .frame(width: 32, height: 32)
                }
                
                // Karma
                Button(action: {
                    Haptics.shared.lightTap()
                    onKarmaTap()
                }) {
                    KarmaIcon(color: textColor, orangeDot: true)
                        .frame(width: 32, height: 32)
                }
                
                // Settings
                Button(action: {
                    Haptics.shared.lightTap()
                    onSettingsTap()
                }) {
                    SettingsIcon(color: textColor, orangeDot: true)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.bottom, Spacing.xxl) // Plus bas qu'avant
        }
    }
}
