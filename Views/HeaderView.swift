//
//  HeaderView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct HeaderView: View {
    let karma: Int
    let roast: String
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("Promi")
                    .font(Typography.title1)
                    .foregroundColor(Brand.orange)
                
                Spacer()
                
                Button(action: onAddTap) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Brand.orange)
                }
            }
            
            // Roast Strip
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(karmaColor)
                    .frame(width: 8, height: 8)
                
                Text(roast)
                    .font(Typography.callout)
                    .foregroundColor(Brand.textSecondary)
                
                Spacer()
                
                Text("\(karma)%")
                    .font(Typography.caption)
                    .foregroundColor(Brand.textSecondary)
            }
        }
    }
    
    private var karmaColor: Color {
        if karma >= 90 {
            return Brand.karmaExcellent
        } else if karma >= 70 {
            return Brand.karmaGood
        } else if karma >= 50 {
            return Brand.karmaAverage
        } else {
            return Brand.karmaPoor
        }
    }
}
