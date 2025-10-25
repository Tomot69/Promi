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
    
    var body: some View {
        Button(action: {
            Haptics.shared.lightTap()
            showEditView = true
        }) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Title
                Text(promi.title)
                    .font(Typography.body)
                    .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                    .strikethrough(promi.status == .done)
                    .multilineTextAlignment(.leading)
                
                // Date + Intensity dot
                HStack(spacing: Spacing.xs) {
                    Text(formattedDate)
                        .font(Typography.caption2)
                        .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                    
                    if isOverdue {
                        Circle()
                            .fill(Color.red.opacity(0.6))
                            .frame(width: 3, height: 3)
                    }
                    
                    Spacer()
                    
                    // Intensity indicator (mini orange dot)
                    if promi.intensity > 70 {
                        Circle()
                            .fill(Brand.orange)
                            .frame(width: 3, height: 3)
                    }
                }
                
                // Assignee
                if let assignee = promi.assignee {
                    Text("→ \(assignee)")
                        .font(Typography.caption2)
                        .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.06), lineWidth: 0.3)
            )
            .opacity(promi.status == .done ? 0.3 : 1.0)
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
