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
            HStack(spacing: 24) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSort = option
                        }
                        Haptics.shared.tinyPop()
                    }) {
                        VStack(spacing: 4) {
                            Text(option.rawValue)
                                .font(.system(size: 13, weight: selectedSort == option ? .semibold : .regular))
                                .foregroundColor(
                                    selectedSort == option
                                    ? Brand.orange.opacity(0.85)
                                    : textColor.opacity(0.4)
                                )
                            
                            if selectedSort == option {
                                Rectangle()
                                    .fill(Brand.orange.opacity(0.6))
                                    .frame(height: 1)
                                    .transition(.scale)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }
}
