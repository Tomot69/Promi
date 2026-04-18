//
//  PublicChallengeView.swift
//  Promi
//
//  "Défi public" : partager un Promi en story avec un compte à
//  rebours visible. L'image exportée montre le titre du Promi,
//  le timer "il reste X jours", et un QR code / lien vers l'app.
//  C'est le hook viral de Promi — accountability publique.
//

import SwiftUI

struct PublicChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore

    let promi: PromiItem

    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @State private var isPreparingShare = false

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    private var timeRemaining: String {
        let now = Date()
        let diff = Calendar.current.dateComponents(
            [.day, .hour, .minute], from: now, to: promi.dueDate
        )
        let days = diff.day ?? 0
        let hours = diff.hour ?? 0

        if days > 1 {
            return isFrench ? "\(days) jours" : "\(days) days"
        } else if days == 1 {
            return isFrench ? "1 jour" : "1 day"
        } else if hours > 0 {
            return isFrench ? "\(hours)h" : "\(hours)h"
        } else {
            return isFrench ? "maintenant" : "now"
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Preview de la story challenge
                challengeCard
                    .padding(.horizontal, 40)

                Text(isFrench
                     ? "Partage ce défi en story — tes amis verront le compte à rebours."
                     : "Share this challenge in your story — your friends will see the countdown.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.54))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // CTA
                Button {
                    prepareShare()
                } label: {
                    HStack(spacing: 8) {
                        if isPreparingShare {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text(isFrench ? "Lancer le défi" : "Launch challenge")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.96))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Brand.orange.opacity(0.88))
                    )
                }
                .buttonStyle(.plain)
                .disabled(isPreparingShare)
                .padding(.horizontal, 32)

                Spacer()
            }

            // Close
            Button {
                Haptics.shared.lightTap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.82))
                    .padding(12)
                    .background(Circle().fill(.white.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.top, 16)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }

    // MARK: - Challenge card (le visuel partagé)

    private var challengeCard: some View {
        VStack(spacing: 20) {
            // Timer
            VStack(spacing: 4) {
                Text(isFrench ? "Il reste" : "Time left")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.52))
                    .tracking(1.0)
                    .textCase(.uppercase)

                Text(timeRemaining)
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundColor(Brand.orange)
            }

            // Titre du Promi
            Text(promi.title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 16)

            // Intensité
            HStack(spacing: 6) {
                ForEach(0..<5) { i in
                    Circle()
                        .fill(i < promi.intensity / 20
                              ? Brand.orange.opacity(0.82)
                              : Color.white.opacity(0.12))
                        .frame(width: 8, height: 8)
                }
            }

            // Branding
            Text("promi.app")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.42))
        }
        .padding(.vertical, 36)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Brand.orange.opacity(0.32), lineWidth: 1)
        )
    }

    // MARK: - Share

    private func prepareShare() {
        guard !isPreparingShare else { return }
        Haptics.shared.lightTap()
        isPreparingShare = true

        let renderSize = CGSize(width: 1080, height: 1920)
        let view = ChallengeShareImage(
            title: promi.title,
            timeRemaining: timeRemaining,
            intensityDots: promi.intensity / 20,
            isFrench: isFrench
        )
        .frame(width: renderSize.width, height: renderSize.height)

        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(width: renderSize.width, height: renderSize.height)
        renderer.scale = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let image = renderer.uiImage {
                shareItems = [image]
                showShareSheet = true
            }
            isPreparingShare = false
        }
    }
}

/// Image de rendu pour l'export story (1080×1920).
private struct ChallengeShareImage: View {
    let title: String
    let timeRemaining: String
    let intensityDots: Int
    let isFrench: Bool

    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 48) {
                Spacer()

                VStack(spacing: 12) {
                    Text(isFrench ? "IL RESTE" : "TIME LEFT")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.white.opacity(0.52))
                        .tracking(4.0)

                    Text(timeRemaining)
                        .font(.system(size: 120, weight: .ultraLight))
                        .foregroundColor(Brand.orange)
                }

                Text(title)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 80)

                HStack(spacing: 14) {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(i < intensityDots
                                  ? Brand.orange.opacity(0.82)
                                  : Color.white.opacity(0.12))
                            .frame(width: 18, height: 18)
                    }
                }

                Spacer()

                Text("promi.app")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white.opacity(0.48))
                    .padding(.bottom, 80)
            }
        }
    }
}
