//
//  MesNuéesView.swift
//  Promi
//
//  Phase 2 — Nuées list page accessible from Settings.
//

import SwiftUI

// MARK: - MesNuéesView
//
// Liste des Nuées de l'utilisateur, présentée comme une sheet depuis
// SettingsView. Trois états :
//   1. Empty state — l'utilisateur n'a aucune Nuée encore
//   2. Liste avec Actives uniquement
//   3. Liste avec Actives + Archives (Nuées éphémères expirées)
//
// Design chrome cohérent avec toutes les autres pages : PromiChromePageBackground
// (mood-aware) + cards chrome + accent orange sur "Nuées" dans le titre +
// FAB orange "+ Créer une Nuée" en bas.

struct MesNuéesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var nuéeStore: NuéeStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @State private var showCreateNuée = false
    @State private var selectedNuée: Nuée?

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    private var activeNuées: [Nuée] {
        nuéeStore.activeNuées(for: userStore.localUserId)
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var expiredNuées: [Nuée] {
        nuéeStore.expiredNuées(for: userStore.localUserId)
            .sorted { ($0.expiresAt ?? .distantPast) > ($1.expiresAt ?? .distantPast) }
    }

    private var hasAnyNuées: Bool {
        !activeNuées.isEmpty || !expiredNuées.isEmpty
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                PromiChromePageBackground(
                    pack: currentPack,
                    mood: currentMood,
                    promis: promiStore.promis,
                    languageCode: userStore.selectedLanguage
                )

                VStack(spacing: 0) {
                    topHeader

                    if hasAnyNuées {
                        nuéesScroll
                    } else {
                        emptyState
                    }

                    createButton
                }

                closeButton
                    .padding(.trailing, 20)
                    .padding(.top, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showCreateNuée) {
            CreateNuéeView()
        }
        .sheet(item: $selectedNuée) { nuée in
            NuéeDetailView(nuéeId: nuée.id)
        }
    }

    // MARK: Top header

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleAttributed
                .font(.system(size: 28, weight: .light))

            Text(isEnglish
                 ? "groups, themes, shared swarms"
                 : "groupes, thèmes, essaims partagés")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.54))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    /// "Mes Nuées" / "My Nuées" with "Nuées" in brand orange.
    private var titleAttributed: Text {
        let raw = isEnglish ? "My Nuées" : "Mes Nuées"
        var attributed = AttributedString(raw)
        attributed.foregroundColor = Color.white.opacity(0.94)

        if let range = attributed.range(of: "Nuées") {
            attributed[range].foregroundColor = brandOrange
        }

        return Text(attributed)
    }

    // MARK: Nuées scroll (active + archives)

    private var nuéesScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                if !activeNuées.isEmpty {
                    sectionLabel(isEnglish ? "ACTIVE" : "ACTIVES")
                    ForEach(activeNuées) { nuée in
                        NuéeRowCard(
                            nuée: nuée,
                            promiCount: promiCount(for: nuée),
                            isEnglish: isEnglish,
                            brandOrange: brandOrange,
                            isArchived: false
                        ) {
                            Haptics.shared.lightTap()
                            selectedNuée = nuée
                        }
                    }
                }

                if !expiredNuées.isEmpty {
                    sectionLabel(isEnglish ? "ARCHIVED" : "ARCHIVES")
                        .padding(.top, 8)
                    ForEach(expiredNuées) { nuée in
                        NuéeRowCard(
                            nuée: nuée,
                            promiCount: promiCount(for: nuée),
                            isEnglish: isEnglish,
                            brandOrange: brandOrange,
                            isArchived: true
                        ) {
                            Haptics.shared.lightTap()
                            selectedNuée = nuée
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 78, height: 78)
                Circle()
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                    .frame(width: 78, height: 78)
                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Color.white.opacity(0.78))
            }

            VStack(spacing: 4) {
                Text(isEnglish ? "No Nuée yet" : "Aucune Nuée pour l’instant")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.78))

                Text(isEnglish
                     ? "create one to share Promis with a small circle"
                     : "crées-en une pour partager des Promis avec un petit cercle")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.46))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Create button (FAB-like, full width)

    private var createButton: some View {
        Button {
            Haptics.shared.lightTap()
            showCreateNuée = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                Text(isEnglish ? "Create a Nuée" : "Créer une Nuée")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Color.white.opacity(0.96))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(brandOrange.opacity(0.86))
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 0.6)
                }
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    // MARK: Close button

    private var closeButton: some View {
        Button {
            Haptics.shared.lightTap()
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.86))
                Text(isEnglish ? "Close" : "Fermer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.92))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
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

    // MARK: Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.0)
            .foregroundColor(Color.white.opacity(0.46))
            .padding(.leading, 4)
    }

    private func promiCount(for nuée: Nuée) -> Int {
        promiStore.promis.filter { $0.nuéeId == nuée.id }.count
    }
}

// MARK: - NuéeRowCard

private struct NuéeRowCard: View {
    let nuée: Nuée
    let promiCount: Int
    let isEnglish: Bool
    let brandOrange: Color
    let isArchived: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                iconBadge

                VStack(alignment: .leading, spacing: 4) {
                    Text(nuée.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.white.opacity(isArchived ? 0.66 : 0.94))
                        .lineLimit(1)

                    Text(nuée.localizedSubtitle(isEnglish: isEnglish))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.white.opacity(isArchived ? 0.42 : 0.56))
                        .lineLimit(1)
                }

                Spacer(minLength: 10)

                VStack(spacing: 2) {
                    Text("\(promiCount)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.white.opacity(isArchived ? 0.62 : 0.92))

                    Text("Promi" + (promiCount > 1 ? "s" : ""))
                        .font(.system(size: 9, weight: .regular))
                        .tracking(0.6)
                        .foregroundColor(Color.white.opacity(0.46))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.42))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(isArchived ? 0.03 : 0.05))
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(isArchived ? 0.08 : 0.12), lineWidth: 0.6)
                }
            )
            .opacity(isArchived ? 0.74 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(brandOrange.opacity(isArchived ? 0.18 : 0.32))
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(brandOrange.opacity(isArchived ? 0.24 : 0.46), lineWidth: 0.6)

            Image(systemName: nuée.displayIconGlyph)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white.opacity(isArchived ? 0.62 : 0.96))
        }
        .frame(width: 42, height: 42)
    }
}
