//
//  MinimalSortTabsView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct MinimalSortTabsView: View {
    @Binding var selectedSort: SortOption
    let textColor: Color
    let accentColor: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xl) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedSort = option
                        Haptics.shared.lightTap()
                    }) {
                        VStack(spacing: Spacing.xxs) {
                            Text(option.rawValue)
                                .font(Typography.caption)
                                .foregroundColor(selectedSort == option ? accentColor : textColor.opacity(0.4))
                            
                            // Underline ultra-subtil
                            if selectedSort == option {
                                Rectangle()
                                    .fill(accentColor.opacity(0.6))
                                    .frame(height: 0.5) // Ultra-fin
                                    .transition(.opacity)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 0.5)
                            }
                        }
                        .frame(minWidth: 50)
                    }
                    .disabled(option == .groups) // Premium lock
                    .opacity(option == .groups ? 0.3 : 1.0)
                }
            }
        }
    }
}
