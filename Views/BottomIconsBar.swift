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
            
            HStack(spacing: 28) {
                
                floatingIcon("tray", action: onDraftTap)
                floatingIcon("circle.lefthalf.filled", action: onPaletteTap)
                floatingIcon("flame", action: onKarmaTap)
                floatingIcon("gearshape", action: onSettingsTap)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.03))
                    .blur(radius: 10)
            )
            .overlay(
                Capsule()
                    .stroke(Brand.hairline, lineWidth: 0.5)
            )
            .padding(.bottom, 34)
        }
    }
    
    private func floatingIcon(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            Haptics.shared.lightTap()
            action()
        }) {
            Image(systemName: name)
                .font(.system(size: 18, weight: .light))
                .foregroundColor(Brand.textSecondary)
                .frame(width: 32, height: 32)
        }
    }
}
