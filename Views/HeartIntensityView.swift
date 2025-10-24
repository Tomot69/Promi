//
//  HeartIntensityView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct HeartIntensityView: View {
    @Binding var intensity: Int
    @State private var lastHapticValue = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Intensité")
                .font(Typography.callout)
                .foregroundColor(Brand.textSecondary)
            
            HStack(spacing: Spacing.md) {
                // Heart icon (simplified)
                ZStack {
                    Circle()
                        .stroke(Brand.orange, lineWidth: 2)
                        .frame(width: 40, height: 40)
                    
                    Text("❤️")
                        .font(.system(size: 20))
                        .opacity(Double(intensity) / 100.0)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Slider(value: Binding(
                        get: { Double(intensity) },
                        set: { newValue in
                            let rounded = Int(newValue)
                            intensity = rounded
                            
                            // Haptic every 10%
                            if rounded / 10 != lastHapticValue / 10 {
                                Haptics.shared.lightTap()
                                lastHapticValue = rounded
                            }
                        }
                    ), in: 0...100, step: 1)
                    .accentColor(Brand.orange)
                    
                    Text("\(intensity)%")
                        .font(Typography.caption)
                        .foregroundColor(Brand.textSecondary)
                }
            }
        }
    }
}
