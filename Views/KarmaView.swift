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

                        roastText

                        statsBlock
                    }
                    .padding(.bottom, 40)
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
