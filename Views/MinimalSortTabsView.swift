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
            HStack(spacing: Spacing.xxl) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedSort = option
                        Haptics.shared.tinyPop()
                    }) {
                        VStack(spacing: Spacing.xxs) {
                            Text(option.rawValue)
                                .font(Typography.caption)
                                .foregroundColor(selectedSort == option ? accentColor.opacity(0.8) : textColor.opacity(0.3))
                            
                            // Underline ultra-subtil
                            if selectedSort == option {
                                Rectangle()
                                    .fill(accentColor.opacity(0.4))
                                    .frame(height: 0.3)
                                    .transition(.opacity)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 0.3)
                            }
                        }
                        .frame(minWidth: 50)
                    }
                    .disabled(option == .groups)
                    .opacity(option == .groups ? 0.2 : 1.0)
                }
            }
        }
    }
}
