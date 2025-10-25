//
//  MinimalHeaderView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct MinimalHeaderView: View {
    let textColor: Color
    let onAddTap: () -> Void
    
    @State private var logoPulse: CGFloat = 1.0
    @State private var logoRotation: Double = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            // Top bar
            HStack(alignment: .center) {
                Text("Promi")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(Brand.orange.opacity(0.85))
                
                Spacer()
                
                Button(action: {
                    Haptics.shared.tinyPop()
                    onAddTap()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .ultraLight))
                        .foregroundColor(Brand.orange.opacity(0.85))
                }
            }
            
            // Logo centré
            Image("LogoPromi")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(logoPulse)
                .rotationEffect(.degrees(logoRotation))
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 4.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        logoPulse = 1.015
                    }
                    
                    withAnimation(
                        Animation.easeInOut(duration: 6.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        logoRotation = 1.0
                    }
                }
        }
    }
}
