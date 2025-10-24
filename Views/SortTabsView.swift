//
//  SortTabsView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct SortTabsView: View {
    @Binding var selectedSort: SortOption
    
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
                            .foregroundColor(selectedSort == option ? .white : Brand.textSecondary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(selectedSort == option ? Brand.orange : Color.gray.opacity(0.2))
                            )
                    }
                }
            }
        }
    }
}
