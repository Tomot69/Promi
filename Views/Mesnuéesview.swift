//
//  MesNuéesView.swift
//  Promi
//
//  Phase 2 — Nuées list page accessible from the top-right dock cluster.
//
//  Features:
//    • Search bar — filter by name or theme (same pattern as PromiListView)
//    • Sort chips — creation date / type / member count
//    • Two sections — Actives + Archives (éphémères expirées)
//    • Empty state — encouragement to create the first Nuée
//    • No-results state — search yielded nothing
//    • FAB "Create" button — orange accent
//
//  Design chrome cohérent avec toutes les pages chrome de Promi :
//  PromiChromePageBackground (mood-aware) + cards chrome + accent orange
//  sur "Nuées" dans le titre.

import SwiftUI

// MARK: - NuéeSortOption

enum NuéeSortOption: String, CaseIterable, Identifiable {
    case date = "Date"
    case type = "Type"
    case members = "Membres"

    var id: String { rawValue }

    var localizedLabel: (fr: String, en: String) {
        switch self {
        case .date: return ("Date", "Date")
        case .type: return ("Type", "Type")
        case .members: return ("Membres", "Members")
        }
    }
}

// MARK: - MesNuéesView

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
    @State private var searchQuery = ""
    @State private var selectedSort: NuéeSortOption = .date


    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    // MARK: - Data pipeline

    /// Trimmed search query, lowercased for matching.
    private var trimmedQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// All active Nuées for the current user, filtered by search query
    /// and sorted by the selected sort option.
    /// Active Nuées top-level (pas les sous-thématiques, qui sont
    /// visibles à l'intérieur de leur Nuée intime parente).
    private var activeNuées: [Nuée] {
        let base = nuéeStore.activeNuées(for: userStore.localUserId)
            .filter { $0.isTopLevel }
        return filterAndSort(base)
    }

    /// Expired Nuées top-level.
    private var expiredNuées: [Nuée] {
        let base = nuéeStore.expiredNuées(for: userStore.localUserId)
            .filter { $0.isTopLevel }
        return filterAndSort(base)
    }

    /// True when there are any top-level Nuées at all (before search).
    private var hasAnyNuées: Bool {
        let totalActive = nuéeStore.activeNuées(for: userStore.localUserId)
            .filter { $0.isTopLevel }
        let totalExpired = nuéeStore.expiredNuées(for: userStore.localUserId)
            .filter { $0.isTopLevel }
        return !totalActive.isEmpty || !totalExpired.isEmpty
    }

    /// True when the search yields no results but the user has Nuées.
    private var isSearchEmpty: Bool {
        hasAnyNuées && activeNuées.isEmpty && expiredNuées.isEmpty
    }

    /// Filter by search query (name + theme), then sort by selected option.
    private func filterAndSort(_ nuées: [Nuée]) -> [Nuée] {
        let filtered: [Nuée]
        if trimmedQuery.isEmpty {
            filtered = nuées
        } else {
            let needle = trimmedQuery.localizedLowercase
            filtered = nuées.filter { nuée in
                nuée.name.localizedLowercase.contains(needle)
                || (nuée.theme?.localizedLowercase.contains(needle) ?? false)
            }
        }

        switch selectedSort {
        case .date:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .type:
            // Group by kind: thematic first (open groups), then intimate.
            // Within each group, sort by creation date descending.
            return filtered.sorted { lhs, rhs in
                if lhs.kind != rhs.kind {
                    return lhs.kind == .thematic
                }
                return lhs.createdAt > rhs.createdAt
            }
        case .members:
            // Most members first, then by creation date for ties.
            return filtered.sorted { lhs, rhs in
                let lc = lhs.totalMemberCount
                let rc = rhs.totalMemberCount
                if lc != rc { return lc > rc }
                return lhs.createdAt > rhs.createdAt
            }
        }
    }

    // MARK: - Body

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
                    searchBar
                    sortBar

                    if !hasAnyNuées {
                        emptyState
                    } else if isSearchEmpty {
                        noResultsState
                    } else {
                        nuéesScroll
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

    // MARK: - Top header

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
            attributed[range].foregroundColor = Brand.orange
        }

        return Text(attributed)
    }

    // MARK: - Search bar

    @ViewBuilder
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.56))

            TextField(
                "",
                text: $searchQuery,
                prompt: Text(isEnglish
                             ? "Search a Nuée…"
                             : "Rechercher une Nuée…")
                    .foregroundColor(Color.white.opacity(0.40))
            )
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(true)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.white.opacity(0.94))

            if !trimmedQuery.isEmpty {
                Button(action: {
                    Haptics.shared.lightTap()
                    searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.54))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(chromeRoundedRect(radius: 14))
        .padding(.horizontal, 22)
        .padding(.bottom, 10)
    }

    // MARK: - Sort bar

    private var sortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NuéeSortOption.allCases) { option in
                    sortChip(option)
                }
            }
            .padding(.horizontal, 22)
        }
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func sortChip(_ option: NuéeSortOption) -> some View {
        let isSelected = selectedSort == option
        let label = isEnglish ? option.localizedLabel.en : option.localizedLabel.fr

        Button(action: {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                selectedSort = option
            }
        }) {
            Text(label)
                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                .foregroundColor(Color.white.opacity(isSelected ? 0.96 : 0.66))
                .padding(.horizontal, 14)
                .frame(height: 30)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(isSelected ? 0.12 : 0.00))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    Color.white.opacity(isSelected ? 0.20 : 0.10),
                                    lineWidth: 0.6
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Nuées scroll (active + archives)

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

    // MARK: - Empty state (no Nuées at all)

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
                Text(isEnglish ? "No Nuée yet" : "Aucune Nuée pour l'instant")
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

    // MARK: - No results state (search returned nothing)

    private var noResultsState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .light))
                .foregroundColor(Color.white.opacity(0.42))

            Text(isEnglish
                 ? "No Nuée matches \"\(trimmedQuery)\""
                 : "Aucune Nuée ne correspond à \"\(trimmedQuery)\"")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white.opacity(0.58))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Create button (FAB-like, full width)

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
                        .fill(Brand.orange.opacity(0.86))
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

    // MARK: - Close button

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

    // MARK: - Helpers

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

    /// Chrome background for search bar and other rounded containers.
    private func chromeRoundedRect(radius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white.opacity(0.05))
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
        }
    }
}

// MARK: - NuéeRowCard

private struct NuéeRowCard: View {
    let nuée: Nuée
    let promiCount: Int
    let isEnglish: Bool
    let isArchived: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                iconBadge

                VStack(alignment: .leading, spacing: 4) {
                    Text(nuée.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.white.opacity(isArchived ? 0.54 : 0.92))
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(nuée.localizedSubtitle(isEnglish: isEnglish))
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.white.opacity(isArchived ? 0.38 : 0.52))
                            .lineLimit(1)

                        if promiCount > 0 {
                            Text("· \(promiCount) promi\(promiCount > 1 ? "s" : "")")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(Color.white.opacity(isArchived ? 0.32 : 0.46))
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(isArchived ? 0.22 : 0.34))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(isArchived ? 0.03 : 0.05))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(isArchived ? 0.06 : 0.12), lineWidth: 0.6)
                }
            )
        }
        .buttonStyle(.plain)
    }

    private var iconBadge: some View {
        // Badge uses the Nuée's own swatch color for visual identity.
        // SF Symbol matches CreateNuéeView's kind cards for cohérence:
        //   .thematic → "tag"
        //   .intimate → "lock.heart"
        let badgeColor = NuéePalette.color(fromHex: nuée.moodHintRawValue) ?? Brand.orange

        return ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(badgeColor.opacity(isArchived ? 0.14 : 0.28))
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(badgeColor.opacity(isArchived ? 0.22 : 0.48), lineWidth: 0.6)

            Image(systemName: nuée.displayIconGlyph)
                .font(.system(size: 17, weight: .light))
                .foregroundColor(Color.white.opacity(isArchived ? 0.56 : 0.94))
                .shadow(color: badgeColor.opacity(0.36), radius: 3, x: 0, y: 1)
        }
        .frame(width: 44, height: 44)
    }
}
