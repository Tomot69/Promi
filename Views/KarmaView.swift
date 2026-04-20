//
//  KarmaView.swift
//  Promi
//
//  Created on 25/10/2025.
//

import SwiftUI

// MARK: - KarmaView
//
// Page Karma (bouton étoile). Même chrome que PromiListView / DraftsView :
// mood home background + ultraThinMaterial + dark tint. Les couleurs
// d'accent (Brand.karmaExcellent/karmaGood/karmaAverage/karmaPoor, l'orange
// de Fermer) sont préservées telles quelles. Seul le background et les
// couleurs de texte ont été adaptés au chrome sombre pour la lisibilité.

struct KarmaView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var karmaStore: KarmaStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @State private var showPaywall = false

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue


    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PromiChromePageBackground(
                    pack: currentPack,
                    mood: currentMood,
                    promis: promiStore.promis,
                    languageCode: userStore.selectedLanguage
                )

                ScrollView {
                    VStack(spacing: 32) {
                        header

                        streakBadge

                        karmaGraph

                        roastText

                        statsBlock
                    }
                    .padding(.bottom, 40)
                }
                .onAppear {
                    karmaStore.loadHistory()
                }

                // Promi Plus : collé en bas de l'écran, hors du scroll,
                // toujours visible comme un footer persistant.
                if !userStore.isPremium {
                    VStack(spacing: 0) {
                        Spacer()
                        promiPlusCard
                            .padding(.bottom, 32)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topTrailing) {
                closeButton
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
            }
        }
    }

    // MARK: - Header (with orange "Karma" accent word)

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 16) {
            Text("Karma")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(Brand.orange)

            Text("\(karmaStore.karmaState.percentage)%")
                .font(.system(size: 72, weight: .ultraLight))
                .foregroundColor(karmaColor)
                .accessibilityLabel("Karma \(karmaStore.karmaState.percentage) percent")
        }
        .padding(.top, 64)
    }

    // MARK: - Roast text

    @ViewBuilder
    private var roastText: some View {
        Text(karmaStore.getRoast(language: userStore.selectedLanguage))
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color.white.opacity(0.66))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }

    // MARK: - Stats block

    @ViewBuilder
    private var statsBlock: some View {
        VStack(spacing: 12) {
            KarmaStatRow(
                label: "Total",
                value: "\(karmaStore.karmaState.totalPromis)",
                accent: Color.white.opacity(0.90)
            )

            KarmaStatRow(
                label: "Tenus",
                value: "\(karmaStore.karmaState.completedPromis)",
                accent: Brand.karmaGood
            )

            KarmaStatRow(
                label: "Ratés",
                value: "\(karmaStore.karmaState.failedPromis)",
                accent: Brand.karmaPoor
            )

            KarmaStatRow(
                label: "En cours",
                value: "\(karmaStore.karmaState.pendingPromis)",
                accent: Brand.karmaAverage
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Promi Plus card

    @ViewBuilder
    private var promiPlusCard: some View {
        let isFrench = !userStore.selectedLanguage.starts(with: "en")

        Button {
            Haptics.shared.lightTap()
            showPaywall = true
        } label: {
            VStack(spacing: 10) {
                HStack(spacing: 0) {
                    Text("Promi")
                        .foregroundColor(Brand.orange)
                    Text(" Plus")
                        .foregroundColor(Color.white.opacity(0.92))
                }
                .font(.system(size: 16, weight: .light))

                Text(isFrench
                     ? "Promi illimités, Nuées illimitées, social complet."
                     : "Unlimited Promis, unlimited Nuées, full social.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.54))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Text(isFrench ? "Découvrir →" : "Discover →")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Brand.orange.opacity(0.86))
                    .padding(.top, 2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Brand.orange.opacity(0.28), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .sheet(isPresented: $showPaywall) {
            PromiPlusPaywallView()
                .environmentObject(userStore)
                .environmentObject(promiStore)
        }
    }

    // MARK: - Close button (same chrome as other pages)

    @ViewBuilder
    private var closeButton: some View {
        Button(action: {
            Haptics.shared.lightTap()
            dismiss()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.82))

                Text("Fermer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.94))
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(
                ZStack {
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)

                    Capsule(style: .continuous)
                        .fill(Color.black.opacity(0.22))

                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Streak badge

    @ViewBuilder
    private var streakBadge: some View {
        let streak = karmaStore.currentStreak
        if streak > 0 {
            HStack(spacing: 10) {
                // Flamme
                Text(streak >= 30 ? "🔥" : (streak >= 7 ? "✨" : "⚡"))
                    .font(.system(size: 22))

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(streak) \(streak == 1 ? (isEnglish ? "day" : "jour") : (isEnglish ? "days" : "jours"))")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.92))
                    Text(isEnglish ? "Current streak" : "Série en cours")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.48))
                }

                Spacer()

                if karmaStore.longestStreak > streak {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(karmaStore.longestStreak)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Brand.orange.opacity(0.72))
                        Text(isEnglish ? "best" : "record")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.38))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                }
            )
            .padding(.horizontal, 20)
        }
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    // MARK: - Karma graph (last 30 days)

    @ViewBuilder
    private var karmaGraph: some View {
        let history = karmaStore.karmaHistory.suffix(30)
        if history.count >= 2 {
            VStack(alignment: .leading, spacing: 8) {
                Text(isEnglish ? "Last 30 days" : "30 derniers jours")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.0)
                    .foregroundColor(Color.white.opacity(0.48))

                GeometryReader { geo in
                    let w = geo.size.width
                    let h: CGFloat = 100
                    let points = Array(history)
                    let minVal = max(0, (points.map(\.value).min() ?? 0) - 5)
                    let maxVal = min(100, (points.map(\.value).max() ?? 100) + 5)
                    let range = max(CGFloat(maxVal - minVal), 1)

                    ZStack(alignment: .topLeading) {
                        // Grid lines
                        ForEach([25, 50, 75, 100], id: \.self) { line in
                            if line >= minVal && line <= maxVal {
                                let y = h - ((CGFloat(line - minVal) / range) * h)
                                Path { p in
                                    p.move(to: CGPoint(x: 0, y: y))
                                    p.addLine(to: CGPoint(x: w, y: y))
                                }
                                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                            }
                        }

                        // Courbe
                        Path { path in
                            for (i, entry) in points.enumerated() {
                                let x = w * CGFloat(i) / CGFloat(max(points.count - 1, 1))
                                let y = h - ((CGFloat(entry.value - minVal) / range) * h)
                                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [Brand.karmaPoor, Brand.karmaAverage, Brand.karmaGood, Brand.karmaExcellent],
                                startPoint: .bottom,
                                endPoint: .top
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )

                        // Point actuel
                        if let last = points.last {
                            let x = w
                            let y = h - ((CGFloat(last.value - minVal) / range) * h)
                            Circle()
                                .fill(karmaColor)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }
                    }
                    .frame(height: h)
                }
                .frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                }
            )
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Karma color (same thresholds and palette as before)

    private var karmaColor: Color {
        let karma = karmaStore.karmaState.percentage
        if karma >= 90 { return Brand.karmaExcellent }
        else if karma >= 70 { return Brand.karmaGood }
        else if karma >= 50 { return Brand.karmaAverage }
        else { return Brand.karmaPoor }
    }
}

// MARK: - Karma stat row (chrome card)

struct KarmaStatRow: View {
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.white.opacity(0.66))

            Spacer()

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(accent)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
            }
        )
    }
}
