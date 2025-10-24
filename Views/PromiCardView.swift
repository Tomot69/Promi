//
//  PromiCardView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct PromiCardView: View {
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    
    let promi: PromiItem
    @State private var offset: CGFloat = 0
    @State private var showComments = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(promi.title)
                    .font(Typography.bodyEmphasis)
                    .foregroundColor(Brand.textPrimary)
                    .strikethrough(promi.status == .done)
                
                HStack(spacing: Spacing.xxs) {
                    Text(formattedDate)
                        .font(Typography.caption)
                        .foregroundColor(Brand.textSecondary)
                    
                    if isOverdue {
                        Text("(!)")
                            .font(Typography.caption)
                            .foregroundColor(.red)
                    }
                    
                    Text(promi.importance.emoji)
                        .font(Typography.caption)
                }
                
                if let assignee = promi.assignee {
                    Text("Pour : \(assignee)")
                        .font(Typography.caption)
                        .foregroundColor(Brand.textSecondary)
                }
                
                // Social actions
                HStack(spacing: Spacing.md) {
                    BravoButton(
                        promiId: promi.id,
                        count: promiStore.getBravosCount(for: promi.id),
                        isActive: promiStore.hasBravo(promiId: promi.id, userId: userStore.localUserId)
                    )
                    
                    Button(action: { showComments = true }) {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 14))
                            Text("\(promiStore.getCommentsCount(for: promi.id))")
                                .font(Typography.caption)
                        }
                        .foregroundColor(Brand.textSecondary)
                    }
                }
                .padding(.top, Spacing.xxs)
            }
            
            Spacer()
            
            if promi.status == .done {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .opacity(promi.status == .done ? Opacity.secondary : Opacity.opaque)
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation.width
                }
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        // Swipe right: Done/Undo
                        if promi.status == .open {
                            promiStore.markAsDone(promi)
                        } else {
                            promiStore.markAsOpen(promi)
                        }
                    }
                    withAnimation(AnimationPreset.spring) {
                        offset = 0
                    }
                }
        )
        .sheet(isPresented: $showComments) {
            CommentsView(promiId: promi.id)
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
