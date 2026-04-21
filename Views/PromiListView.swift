import SwiftUI

// MARK: - PromiListView
//
// Page Mes/Mon Promi (bouton œil). Design chrome cohérent avec les dropdown
// menus (tri, +) : mood home background + ultraThinMaterial + dark tint. Le
// mot "Promi" dans le titre est coloré en orange comme accent de marque.
// Trois segments : En cours, Brouillons, Accomplis. Le titre devient "Mon
// Promi" uniquement s'il existe exactement un Promi (actif ou accompli) ;
// sinon "Mes Promi".

struct PromiListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @Binding var sortOption: PromiFieldSortOption
    @Binding var selectedPromi: PromiItem?

    @State private var selectedSegment: PromiListSegment = .active
    @State private var query: String = ""

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Same chrome as the tri/+ dropdown menus: live Voronoi
                // backdrop + ultraThinMaterial + dark tint at the exact
                // CompactMenuSurface opacity (0.18/0.10) so the mood's
                // abstract color patches breathe through identically.
                PromiChromePageBackground(
                    pack: currentPack,
                    mood: currentMood,
                    promis: promiStore.promis,
                    languageCode: userStore.selectedLanguage
                )

                VStack(spacing: 0) {
                    topHeader
                    searchBar
                    segmentBar
                    sortBar
                    contentArea
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Data

    private var activePromis: [PromiItem] {
        promiStore.promis.filter { $0.status != .done }
    }

    private var donePromis: [PromiItem] {
        promiStore.promis.filter { $0.status == .done }
    }

    private var useSingular: Bool {
        promiStore.promis.count == 1
    }

    private var displayedPromis: [PromiItem] {
        let source = selectedSegment == .active ? activePromis : donePromis
        let searched = filteredPromis(source)
        return sortedPromis(searched, by: sortOption, doneSegment: selectedSegment == .done)
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    // MARK: - Top header with orange "Promi" accent

    @ViewBuilder
    private var topHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                titleAttributed
                    .font(.system(size: 32, weight: .light))

                Text(dynamicSubtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
                    .tracking(0.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            closeButton
                .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 16)
    }

    /// Dynamic subtitle: "3 tenus · 5 à venir" — reflects the real state
    /// of the user's promises at a glance.
    private var dynamicSubtitle: String {
        let doneCount = donePromis.count
        let activeCount = activePromis.count

        if doneCount == 0 && activeCount == 0 {
            return isEnglish ? "the canvas is quiet" : "la toile est calme"
        }

        var parts: [String] = []
        if doneCount > 0 {
            parts.append(isEnglish
                ? "\(doneCount) kept"
                : "\(doneCount) tenu\(doneCount > 1 ? "s" : "")")
        }
        if activeCount > 0 {
            parts.append(isEnglish
                ? "\(activeCount) ahead"
                : "\(activeCount) à venir")
        }
        return parts.joined(separator: " · ")
    }

    /// "Mes " (or "Mon ") in near-white + "Promi" in the brand orange.
    /// Built as a single AttributedString — the iOS 26+ idiomatic way to
    /// style parts of a Text (Text + concatenation is deprecated).
    private var isEnglish: Bool {
        userStore.selectedLanguage.lowercased().starts(with: "en")
    }

    private var titleAttributed: Text {
        let prefix = isEnglish
            ? (useSingular ? "My " : "My ")
            : (useSingular ? "Mon " : "Mes ")
        var attributed = AttributedString(prefix + "Promi")
        attributed.foregroundColor = Color.white.opacity(0.94)
        if let range = attributed.range(of: "Promi") {
            attributed[range].foregroundColor = Color(red: 0.98, green: 0.56, blue: 0.22)
        }
        return Text(attributed)
    }

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
            .background(chromePill)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var chromePill: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)

            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.22))

            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
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
                text: $query,
                prompt: Text("Rechercher un Promi ou une personne…")
                    .foregroundColor(Color.white.opacity(0.40))
            )
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(true)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.white.opacity(0.94))

            if !trimmedQuery.isEmpty {
                Button(action: {
                    Haptics.shared.lightTap()
                    query = ""
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
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    // MARK: - Segment bar (3 segments: active / drafts / done)

    @ViewBuilder
    private var segmentBar: some View {
        HStack(spacing: 8) {
            segmentButton(.active, title: "À venir", count: activePromis.count)
            segmentButton(.done, title: "Accomplis", count: donePromis.count)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func segmentButton(
        _ segment: PromiListSegment,
        title: String,
        count: Int
    ) -> some View {
        let isSelected = selectedSegment == segment

        Button(action: {
            Haptics.shared.tinyPop()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                selectedSegment = segment
            }
        }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.96) : Color.white.opacity(0.26))
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.96 : 0.68))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text("\(count)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.82 : 0.50))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(isSelected ? 0.16 : 0.08))
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.10 : 0.00))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                Color.white.opacity(isSelected ? 0.18 : 0.08),
                                lineWidth: 0.6
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sort chips (hidden in drafts segment)

    @ViewBuilder
    private var sortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PromiFieldSortOption.allCases, id: \.self) { option in
                    sortChip(option)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func sortChip(_ option: PromiFieldSortOption) -> some View {
        let isSelected = sortOption == option

        Button(action: {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                sortOption = option
            }
        }) {
            Text(option.rawValue)
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

    // MARK: - Content area (promis or drafts depending on segment)

    @ViewBuilder
    private var contentArea: some View {
        switch selectedSegment {
        case .active:
            if displayedPromis.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(horizonSections, id: \.title) { section in
                            if !section.promis.isEmpty {
                                horizonHeader(section.title, icon: section.icon)

                                ForEach(section.promis) { promi in
                                    PromiListRowCard(
                                        promi: promi,
                                        languageCode: userStore.selectedLanguage,
                                        bravoCount: promiStore.getBravosCount(for: promi.id),
                                        commentCount: promiStore.getCommentsCount(for: promi.id),
                                        onOpen: {
                                            Haptics.shared.lightTap()
                                            dismiss()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                                selectedPromi = promi
                                            }
                                        },
                                        onToggleDone: {
                                            Haptics.shared.tinyPop()
                                            togglePromiDone(promi)
                                        }
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
            }

        case .done:
            if displayedPromis.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(displayedPromis) { promi in
                            DonePromiCard(
                                promi: promi,
                                languageCode: userStore.selectedLanguage,
                                onOpen: {
                                    Haptics.shared.lightTap()
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                        selectedPromi = promi
                                    }
                                },
                                onReopen: {
                                    Haptics.shared.tinyPop()
                                    togglePromiDone(promi)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
            }
        }
    }

    // MARK: - Horizon sections (À venir grouping)

    private struct HorizonSection {
        let title: String
        let icon: String
        let promis: [PromiItem]
    }

    private var horizonSections: [HorizonSection] {
        let cal = Calendar.current
        let now = Date()
        let endOfToday = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now) ?? now)
        let endOfWeek = cal.date(byAdding: .day, value: 7, to: cal.startOfDay(for: now)) ?? now

        var today: [PromiItem] = []
        var thisWeek: [PromiItem] = []
        var later: [PromiItem] = []
        var floating: [PromiItem] = []

        for promi in displayedPromis {
            if promi.kind == .floating {
                floating.append(promi)
            } else if promi.dueDate < endOfToday {
                today.append(promi)
            } else if promi.dueDate < endOfWeek {
                thisWeek.append(promi)
            } else {
                later.append(promi)
            }
        }

        return [
            HorizonSection(title: "Aujourd'hui", icon: "sun.max", promis: today),
            HorizonSection(title: "Cette semaine", icon: "calendar", promis: thisWeek),
            HorizonSection(title: "Plus tard", icon: "clock", promis: later),
            HorizonSection(title: "En l'air", icon: "wind", promis: floating)
        ]
    }

    @ViewBuilder
    private func horizonHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(red: 0.98, green: 0.56, blue: 0.22).opacity(0.78))

            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.48))
                .tracking(1.0)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 8)
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyState: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 76, height: 76)

                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                        .frame(width: 76, height: 76)

                    if selectedSegment == .active {
                        PinkyPromiseGlyph(isDarkField: true)
                            .frame(width: 36, height: 36)
                    } else {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(Color.white.opacity(0.68))
                    }
                }

                Text(emptyTitle)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(Color.white.opacity(0.88))

                Text(emptySubtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTitle: String {
        switch selectedSegment {
        case .active:
            if trimmedQuery.isEmpty {
                return isEnglish ? "The canvas is quiet" : "La toile est calme"
            }
            return isEnglish ? "No results" : "Aucun résultat"
        case .done:
            if trimmedQuery.isEmpty {
                return isEnglish ? "No promises kept yet" : "Pas encore de promesses tenues"
            }
            return isEnglish ? "No results" : "Aucun résultat"
        }
    }

    private var emptySubtitle: String {
        switch selectedSegment {
        case .active:
            return trimmedQuery.isEmpty
                ? "Crée ta prochaine promesse. Le champ attend un nouveau foyer."
                : "Ajuste la recherche ou le tri pour retrouver ton Promi."
        case .done:
            return trimmedQuery.isEmpty
                ? "Chaque promesse tenue laissera une trace ici — un souvenir vivant."
                : "Ajuste la recherche pour retrouver une promesse accomplie."
        }
    }

    // MARK: - Chrome surface helper

    @ViewBuilder
    private func chromeRoundedRect(radius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white.opacity(0.06))

            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
    }

    // MARK: - Filtering & sorting

    private func filteredPromis(_ source: [PromiItem]) -> [PromiItem] {
        guard !trimmedQuery.isEmpty else { return source }

        let needle = trimmedQuery.localizedLowercase

        return source.filter { promi in
            let title = promi.title.localizedLowercase
            let assignee = (promi.assignee ?? "").localizedLowercase
            let fullTitle = title.hasPrefix("promi") ? title : "promi \(title)"

            return title.contains(needle)
                || fullTitle.contains(needle)
                || assignee.contains(needle)
        }
    }

    private func sortedPromis(
        _ promis: [PromiItem],
        by option: PromiFieldSortOption,
        doneSegment: Bool
    ) -> [PromiItem] {
        switch option {
        case .date:
            if doneSegment {
                return promis.sorted(by: { (lhs: PromiItem, rhs: PromiItem) in
                    let left = lhs.completedAt ?? lhs.createdAt
                    let right = rhs.completedAt ?? rhs.createdAt
                    return left > right
                })
            } else {
                return promis.sorted(by: { (lhs: PromiItem, rhs: PromiItem) in
                    lhs.dueDate < rhs.dueDate
                })
            }

        case .urgency:
            let now = Date()
            return promis.sorted(by: { (lhs: PromiItem, rhs: PromiItem) in
                abs(lhs.dueDate.timeIntervalSince(now)) < abs(rhs.dueDate.timeIntervalSince(now))
            })

        case .person:
            return promis.sorted(by: { (lhs: PromiItem, rhs: PromiItem) in
                let left = (lhs.assignee ?? "").localizedLowercase
                let right = (rhs.assignee ?? "").localizedLowercase
                if left == right {
                    return lhs.createdAt < rhs.createdAt
                }
                return left < right
            })

        case .importance:
            return promis.sorted(by: { (lhs: PromiItem, rhs: PromiItem) in
                if lhs.intensity == rhs.intensity {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhs.intensity > rhs.intensity
            })

        case .inspiration:
            return promis.sorted(by: { (lhs: PromiItem, rhs: PromiItem) in
                stableRank(lhs) < stableRank(rhs)
            })

        case .nuée:
            return promis.sorted(by: { (lhs: PromiItem, rhs: PromiItem) in
                let lhsKey = lhs.nuéeId?.uuidString ?? "zzz"
                let rhsKey = rhs.nuéeId?.uuidString ?? "zzz"
                if lhsKey == rhsKey {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhsKey < rhsKey
            })
        }
    }

    private func stableRank(_ promi: PromiItem) -> Int {
        var hasher = Hasher()
        hasher.combine(promi.id)
        hasher.combine(promi.createdAt.timeIntervalSinceReferenceDate)
        return abs(hasher.finalize())
    }

    private func togglePromiDone(_ promi: PromiItem) {
        if promi.status == .done {
            promiStore.markAsOpen(promi)
        } else {
            promiStore.markAsDone(promi)
        }
    }
}

// MARK: - Segment enum

private enum PromiListSegment {
    case active
    case done
}

// MARK: - Promi row card (chrome over mood background)

private struct PromiListRowCard: View {
    let promi: PromiItem
    let languageCode: String
    let bravoCount: Int
    let commentCount: Int
    let onOpen: () -> Void
    let onToggleDone: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 12) {
                header
                titleBlock
                footer
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            statusDot

            VStack(alignment: .leading, spacing: 1) {
                Text(kindLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.80))
                    .tracking(0.3)

                if let assignee = promi.assignee, !assignee.isEmpty {
                    Text(assignee)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.52))
                }
            }

            Spacer()

            toggleDoneButton
        }
    }

    @ViewBuilder
    private var toggleDoneButton: some View {
        Button(action: onToggleDone) {
            HStack(spacing: 6) {
                Image(systemName: promi.status == .done ? "arrow.uturn.backward" : "checkmark")
                    .font(.system(size: 10, weight: .semibold))

                Text(promi.status == .done ? "Rouvrir" : "Valider")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(Color.white.opacity(0.96))
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(promi.status == .done ? 0.08 : 0.18))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(
                                Color.white.opacity(promi.status == .done ? 0.14 : 0.28),
                                lineWidth: 0.6
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusDot: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 9, height: 9)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.24), lineWidth: 0.8)
            )
    }

    @ViewBuilder
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if promi.status == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.34, green: 0.80, blue: 0.60).opacity(0.86))
                }
                Text(fullPromiTitle)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(Color.white.opacity(promi.status == .done ? 0.78 : 0.94))
                    .multilineTextAlignment(.leading)
            }

            Text(promi.status == .done
                 ? (languageCode.starts(with: "en") ? "Promise kept" : "Promesse tenue")
                 : importanceLabel)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(promi.status == .done ? 0.62 : 0.56))
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(secondaryDateLabelTitle)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.42))
                    .tracking(0.5)

                Text(formattedDate(secondaryDate))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.76))
            }

            Spacer()

            // Social (bravo + commentaires)
            if bravoCount > 0 || commentCount > 0 {
                HStack(spacing: 8) {
                    if bravoCount > 0 {
                        HStack(spacing: 3) {
                            PinkyPromiseGlyph(isDarkField: true)
                                .frame(width: 12, height: 12)
                            Text("\(bravoCount)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Brand.orange.opacity(0.76))
                        }
                    }
                    if commentCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 10, weight: .medium))
                            Text("\(commentCount)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(Color.white.opacity(0.52))
                    }
                }
            }

            intensityPill
        }
    }

    @ViewBuilder
    private var intensityPill: some View {
        HStack(spacing: 4) {
            ForEach(0..<dotCount, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.80))
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 22)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.5)
                )
        )
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
    }

    private var fullPromiTitle: String {
        let trimmed = promi.title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let lowered = trimmed.localizedLowercase
        if lowered.hasPrefix("promi") {
            return trimmed
        }
        return "Promi \(trimmed)"
    }

    private var kindLabel: String {
        switch promi.kind {
        case .precise:   return "Précis"
        case .floating:  return "En l’air"
        case .emotional: return "Émotionnel"
        }
    }

    private var importanceLabel: String {
        switch promi.importance {
        case .low:    return "Importance douce"
        case .normal: return "Importance normale"
        case .urgent: return "Importance forte"
        }
    }

    private var secondaryDateLabelTitle: String {
        promi.status == .done ? "ACCOMPLI" : "ÉCHÉANCE"
    }

    private var secondaryDate: Date {
        if promi.status == .done {
            return promi.completedAt ?? promi.createdAt
        }
        return promi.dueDate
    }

    private var statusColor: Color {
        if promi.status == .done {
            return Color(red: 0.34, green: 0.80, blue: 0.60)
        }

        if promi.intensity >= 70 {
            return Color(red: 0.98, green: 0.44, blue: 0.34)
        } else if promi.intensity >= 40 {
            return Color(red: 0.34, green: 0.84, blue: 0.82)
        } else {
            return Color(red: 0.48, green: 0.58, blue: 0.92)
        }
    }

    private var dotCount: Int {
        max(1, min(Int(round(Double(promi.intensity) / 20.0)), 5))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageCode.isEmpty ? "fr_FR" : languageCode)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Done Promi card (album-style memory)
//
// Each accomplished Promi is presented as a small memory card — not a
// checked-off task. Shows the title, the completion date, how many days
// it took to fulfill, and a poetic one-liner that celebrates the act
// of keeping a promise.

private struct DonePromiCard: View {
    let promi: PromiItem
    let languageCode: String
    let onOpen: () -> Void
    let onReopen: () -> Void


    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                // Title
                Text(fullPromiTitle)
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Color.white.opacity(0.92))
                    .multilineTextAlignment(.leading)

                // Poetic completion note
                Text(poeticNote)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Brand.orange.opacity(0.78))
                    .italic()

                // Footer: completion date + duration + reopen
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACCOMPLI")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.38))
                            .tracking(0.5)

                        Text(formattedCompletionDate)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.68))
                    }

                    Spacer()

                    // Duration pill
                    Text(durationText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.72))
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                                )
                        )
                }

                // Reopen button (discreet)
                HStack {
                    Spacer()
                    Button(action: onReopen) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 9, weight: .semibold))
                            Text("Rouvrir")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(Color.white.opacity(0.52))
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
    }

    private var fullPromiTitle: String {
        let trimmed = promi.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.localizedLowercase
        return lowered.hasPrefix("promi") ? trimmed : "Promi \(trimmed)"
    }

    private var formattedCompletionDate: String {
        let date = promi.completedAt ?? promi.createdAt
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageCode.isEmpty ? "fr_FR" : languageCode)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Number of days between creation and completion.
    private var daysTaken: Int {
        let completion = promi.completedAt ?? Date()
        let interval = completion.timeIntervalSince(promi.createdAt)
        return max(0, Int(interval / 86400))
    }

    private var durationText: String {
        let days = daysTaken
        if days == 0 { return "le jour même" }
        if days == 1 { return "en 1 jour" }
        return "en \(days) jours"
    }

    /// A poetic one-liner based on how long it took to keep the promise.
    /// Adds warmth to what could be a dry "completed" status.
    private var poeticNote: String {
        let days = daysTaken
        if days == 0 { return "tenu sans détour" }
        if days <= 2 { return "promesse rapide, parole solide" }
        if days <= 7 { return "tenu dans la semaine" }
        if days <= 30 { return "la patience a porté ses fruits" }
        return "le temps n'a pas eu raison de cette promesse"
    }
}
