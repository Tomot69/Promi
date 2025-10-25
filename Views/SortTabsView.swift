//
//  SortTabsView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct SortTabsView: View {
    @Binding var selectedSort: SortOption
    let textColor: Color
    let accentColor: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedSort = option
                        Haptics.shared.lightTap()
                    }) {
                        Text(option.rawValue)
                            .font(Typography.callout)
                            .foregroundColor(selectedSort == option ? .white : textColor)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(selectedSort == option ? accentColor : Color.gray.opacity(0.2))
                            )
                    }
                }
            }
        }
    }
}
