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
    
    @State private var showEditView = false
    @State private var showComments = false
    
    private var timeRemaining: String {
        let now = Date()
        let interval = promi.dueDate.timeIntervalSince(now)
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days)j"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "Bientôt"
        }
    }
    
    private var commentsCount: Int {
        promiStore.comments.filter { $0.promiId == promi.id }.count
    }
    
    var body: some View {
        Button(action: {
            Haptics.shared.lightTap()
            showEditView = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(promi.title)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.85))
                            .lineLimit(2)
                        
                        if let assignee = promi.assignee {
                            Text("pour \(assignee)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                    
                    Text(timeRemaining)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(intensityColor)
                            .frame(width: 4, height: 4)
                        
                        Text(intensityLabel)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Haptics.shared.lightTap()
                        showComments = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 12))
                            Text("\(commentsCount)")
                                .font(.system(size: 11, weight: .regular))
                        }
                        .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.06), lineWidth: 0.2)
            )
        }
        .sheet(isPresented: $showEditView) {
            EditPromiView(promi: promi)
        }
        .sheet(isPresented: $showComments) {
            CommentsView(promiId: promi.id)
        }
    }
    
    private var intensityColor: Color {
        let intensity = promi.intensity
        if intensity >= 80 { return Brand.orange.opacity(0.8) }
        else if intensity >= 50 { return Brand.orange.opacity(0.5) }
        else { return Brand.orange.opacity(0.3) }
    }
    
    private var intensityLabel: String {
        let intensity = promi.intensity
        if intensity >= 80 { return "très important" }
        else if intensity >= 50 { return "important" }
        else { return "normal" }
    }
}
