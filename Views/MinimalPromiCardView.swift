//
//  MinimalPromiCardView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

struct MinimalPromiCardView: View {
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    
    let promi: PromiItem
    @State private var offset: CGFloat = 0
    @State private var showEditView = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            Haptics.shared.tinyPop()
            showEditView = true
        }) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Title
                Text(promi.title)
                    .font(Typography.body)
                    .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(promi.status == .done ? 0.3 : 1.0))
                    .strikethrough(promi.status == .done, color: userStore.selectedPalette.textPrimaryColor.opacity(0.2))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
                // Date + Indicators (ultra-discrets)
                HStack(spacing: Spacing.sm) {
                    Text(formattedDate)
                        .font(Typography.caption2)
                        .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                    
                    if isOverdue {
                        Circle()
                            .fill(Color.red.opacity(0.4))
                            .frame(width: 2, height: 2)
                    }
                    
                    Spacer()
                    
                    // Intensity dot (ultra-subtil)
                    if promi.intensity > 70 {
                        Circle()
                            .fill(Brand.orange.opacity(0.6))
                            .frame(width: 2, height: 2)
                    }
                }
                
                // Assignee (ultra-discret)
                if let assignee = promi.assignee {
                    Text("→ \(assignee)")
                        .font(Typography.caption2)
                        .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.3))
                }
            }
            .padding(.vertical, Spacing.lg)
            .padding(.horizontal, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.04), lineWidth: 0.2) // Ultra-fin
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation.width
                }
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        if promi.status == .open {
                            promiStore.markAsDone(promi)
                        } else {
                            promiStore.markAsOpen(promi)
                        }
                        Haptics.shared.gentleNudge()
                    }
                    withAnimation(AnimationPreset.spring) {
                        offset = 0
                    }
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(AnimationPreset.springBouncy) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(AnimationPreset.spring) {
                        isPressed = false
                    }
                }
        )
        .sheet(isPresented: $showEditView) {
            EditPromiView(promi: promi)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: promi.dueDate)
    }
    
    private var isOverdue: Bool {
        promi.status == .open && promi.dueDate < Date()
    }
}
