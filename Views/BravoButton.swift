//
//  BravoButton.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct BravoButton: View {
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    
    let promiId: UUID
    let count: Int
    let isActive: Bool
    
    var body: some View {
        Button(action: toggleBravo) {
            HStack(spacing: 4) {
                Image(systemName: isActive ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: 14))
                Text("\(count)")
                    .font(.system(size: 12, weight: .regular))
            }
            .foregroundColor(isActive ? Brand.orange : userStore.selectedPalette.textSecondaryColor)
        }
    }
    
    private func toggleBravo() {
        if isActive {
            Haptics.shared.lightTap()
        } else {
            let bravo = Bravo(
                promiId: promiId,
                userId: userStore.localUserId
            )
            promiStore.addBravo(bravo)
            Haptics.shared.success()
        }
    }
}
