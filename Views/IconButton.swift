//
//  IconButton.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            Haptics.shared.lightTap()
            withAnimation(AnimationPreset.springBouncy) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AnimationPreset.spring) {
                    isPressed = false
                }
            }
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
    }
}
