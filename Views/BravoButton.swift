//
//  BravoButton.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct BravoButton: View {
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    
    let promiId: UUID
    let count: Int
    let isActive: Bool
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            promiStore.toggleBravo(promiId: promiId, userId: userStore.localUserId)
            
            withAnimation(AnimationPreset.springBouncy) {
                scale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AnimationPreset.spring) {
                    scale = 1.0
                }
            }
        }) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? Brand.orange : Brand.textSecondary)
                
                Text("\(count)")
                    .font(Typography.caption)
                    .foregroundColor(Brand.textSecondary)
            }
            .scaleEffect(scale)
        }
    }
}
