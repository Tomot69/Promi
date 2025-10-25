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
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            Haptics.shared.tinyPop()
            showEditView = true
        }) {
            HStack(spacing: 0) {
                // Barre latérale ultra-fine (orange si haute intensité)
                Rectangle()
                    .fill(promi.intensity > 70 ? Brand.orange.opacity(0.6) : Color.clear)
                    .frame(width: 1.5)
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Title
                    Text(promi.title)
                        .font(Typography.body)
                        .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(promi.status == .done ? 0.25 : 0.95))
                        .strikethrough(promi.status == .done, color: userStore.selectedPalette.textPrimaryColor.opacity(0.15))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(3)
                    
                    // Meta infos (ultra-discret)
                    HStack(spacing: Spacing.sm) {
                        // Date
                        Text(formattedDate)
                            .font(Typography.caption2)
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.35))
                        
                        // Overdue indicator
                        if isOverdue {
                            Text("!")
                                .font(Typography.caption2)
                                .foregroundColor(Color.red.opacity(0.4))
                        }
                        
                        Spacer()
                        
                        // Assignee si présent
                        if let assignee = promi.assignee {
                            Text(assignee)
                                .font(Typography.caption2)
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.3))
                        }
                    }
                }
                .padding(.vertical, Spacing.lg)
                .padding(.horizontal, Spacing.lg)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                // Fond transparent avec contour ultra-subtil
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(isHovered ? userStore.selectedPalette.textPrimaryColor.opacity(0.015) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        userStore.selectedPalette.textPrimaryColor.opacity(0.03),
                                        userStore.selectedPalette.textPrimaryColor.opacity(0.01)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.15
                            )
                    )
            )
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
                    isHovered = true
                }
                .onEnded { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isHovered = false
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
