//
//  KarmaView.swift
//  Promi
//
//  Created on 24/10/2025.
//

import SwiftUI

struct KarmaView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var karmaStore: KarmaStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Jauge circulaire
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                .frame(width: 180, height: 180)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(karmaStore.karmaState.percentage) / 100.0)
                                .stroke(karmaColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                                .animation(AnimationPreset.spring, value: karmaStore.karmaState.percentage)
                            
                            VStack(spacing: Spacing.xxs) {
                                Text("\(karmaStore.karmaState.percentage)%")
                                    .font(.system(size: 48, weight: .semibold))
                                    .foregroundColor(Brand.textPrimary)
                                
                                Text("Karma")
                                    .font(Typography.callout)
                                    .foregroundColor(Brand.textSecondary)
                            }
                        }
                        .padding(.top, Spacing.xl)
                        
                        // Roast
                        Text(karmaStore.getRoast(language: userStore.selectedLanguage))
                            .font(Typography.body)
                            .foregroundColor(Brand.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                        
                        // Badges
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Badges")
                                .font(Typography.title3)
                                .foregroundColor(Brand.textPrimary)
                            
                            ForEach(Badge.allCases, id: \.self) { badge in
                                BadgeRow(
                                    badge: badge,
                                    isUnlocked: karmaStore.karmaState.earnedBadges.contains(badge)
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        
                        Spacer()
                    }
                    .padding(.vertical, Spacing.xl)
                }
            }
            .navigationTitle("Karma Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(Brand.orange)
                }
            }
        }
    }
    
    private var karmaColor: Color {
        let karma = karmaStore.karmaState.percentage
        if karma >= 90 {
            return Brand.karmaExcellent
        } else if karma >= 70 {
            return Brand.karmaGood
        } else if karma >= 50 {
            return Brand.karmaAverage
        } else {
            return Brand.karmaPoor
        }
    }
}

struct BadgeRow: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(isUnlocked ? "✅" : "🔒")
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(badge.title)
                    .font(Typography.bodyEmphasis)
                    .foregroundColor(isUnlocked ? Brand.textPrimary : Brand.textSecondary)
                
                Text(badge.description)
                    .font(Typography.caption)
                    .foregroundColor(Brand.textSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(isUnlocked ? Brand.orange.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }
}
