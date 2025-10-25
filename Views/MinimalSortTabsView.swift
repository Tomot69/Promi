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
            HStack(spacing: Spacing.xxxl) { // Encore plus d'espace
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        withAnimation(AnimationPreset.spring) {
                            selectedSort = option
                        }
                        Haptics.shared.tinyPop()
                    }) {
                        VStack(spacing: Spacing.xxs) {
                            Text(option.rawValue)
                                .font(Typography.caption)
                                .foregroundColor(
                                    selectedSort == option
                                    ? accentColor.opacity(0.9)
                                    : textColor.opacity(0.25)
                                )
                            
                            // Dot au lieu de ligne (plus original)
                            if selectedSort == option {
                                Circle()
                                    .fill(Brand.orange.opacity(0.5))
                                    .frame(width: 3, height: 3)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 3, height: 3)
                            }
                        }
                        .frame(minWidth: 60)
                    }
                    .disabled(option == .groups)
                    .opacity(option == .groups ? 0.15 : 1.0)
                }
            }
            .padding(.horizontal, Spacing.xs)
        }
    }
}
