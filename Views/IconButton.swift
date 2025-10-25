//
//  IconButton.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptics.shared.lightTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundColor(color.opacity(0.6))
                .frame(width: 44, height: 44)
        }
    }
}
