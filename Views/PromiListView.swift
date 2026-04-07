import SwiftUI

struct PromiListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore

    @Binding var sortOption: PromiFieldSortOption
    @Binding var selectedPromi: PromiItem?

    @State private var selectedSegment: PromiListSegment = .active
    @State private var query: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                listBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topHeader
                    segmentBar
                    sortBar
                    contentList
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var activePromis: [PromiItem] {
        promiStore.promis.filter { $0.status != .done }
    }

    private var donePromis: [PromiItem] {
        promiStore.promis.filter { $0.status == .done }
    }

    private var displayedPromis: [PromiItem] {
        let source = selectedSegment == .active ? activePromis : donePromis
        let searched = filteredPromis(source)
        return sortedPromis(searched, by: sortOption, doneSegment: selectedSegment == .done)
    }

    private var emptyTitle: String {
        switch selectedSegment {
        case .active:
            return trimmedQuery.isEmpty ? "Aucun Promi en cours" : "Aucun résultat"
        case .done:
            return trimmedQuery.isEmpty ? "Aucun Promi accompli" : "Aucun résultat"
        }
    }

    private var emptySubtitle: String {
        switch selectedSegment {
        case .active:
            return trimmedQuery.isEmpty
                ? "Vos promesses actives apparaîtront ici, dans une vue simple et rapide."
                : "Ajustez la recherche ou le tri pour retrouver votre Promi."
        case .done:
            return trimmedQuery.isEmpty
                ? "Votre historique des promesses tenues apparaîtra ici."
                : "Ajustez la recherche ou le tri pour retrouver une promesse accomplie."
        }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    @ViewBuilder
    private var listBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.93, blue: 0.90),
                Color(red: 0.90, green: 0.88, blue: 0.84)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    @ViewBuilder
    private var topHeader: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mon Promi")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(Color.black.opacity(0.86))

                    Text("vue claire, complète, pilotable")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.black.opacity(0.46))
                }

                Spacer()

                Button(action: {
                    Haptics.shared.lightTap()
                    dismiss()
                }) {
                    Text("Fermer")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.94, green: 0.47, blue: 0.18))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.72))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.white.opacity(0.72), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                searchField

                Button(action: {
                    Haptics.shared.lightTap()
                    query = ""
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.64))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.72), lineWidth: 1)
                            )

                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.66))
                    }
                    .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .opacity(trimmedQuery.isEmpty ? 0.35 : 1)
                .disabled(trimmedQuery.isEmpty)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 18)
    }

    @ViewBuilder
    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.black.opacity(0.42))

            TextField("Rechercher un Promi ou une personne…", text: $query)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(true)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.black.opacity(0.84))
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.74), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var segmentBar: some View {
        HStack(spacing: 10) {
            segmentButton(.active, title: "En cours", count: activePromis.count)
            segmentButton(.done, title: "Accomplis", count: donePromis.count)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func segmentButton(_ segment: PromiListSegment, title: String, count: Int) -> some View {
        let isSelected = selectedSegment == segment

        Button(action: {
            Haptics.shared.tinyPop()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                selectedSegment = segment
            }
        }) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))

                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule(style: .continuous)
                            .fill(isSelected ? Color.white.opacity(0.22) : Color.black.opacity(0.06))
                    )
            }
            .foregroundColor(isSelected ? .white : Color.black.opacity(0.64))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        isSelected
                        ? Color(red: 0.21, green: 0.30, blue: 0.44)
                        : Color.white.opacity(0.48)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.72), lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var sortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PromiFieldSortOption.allCases, id: \.self) { option in
                    sortChip(option)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
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
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : Color.black.opacity(0.66))
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            isSelected
                            ? Color(red: 0.96, green: 0.39, blue: 0.28)
                            : Color.white.opacity(0.54)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(isSelected ? 0 : 0.76), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var contentList: some View {
        if displayedPromis.isEmpty {
            Spacer()

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.58))
                        .frame(width: 74, height: 74)

                    Image(systemName: selectedSegment == .active ? "sparkles" : "clock.arrow.circlepath")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(Color.black.opacity(0.54))
                }

                Text(emptyTitle)
                    .font(.system(size: 23, weight: .light))
                    .foregroundColor(Color.black.opacity(0.82))

                Text(emptySubtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.black.opacity(0.46))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(displayedPromis) { promi in
                        PromiListRowCard(
                            promi: promi,
                            languageCode: userStore.selectedLanguage,
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
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
    }

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

    private func sortedPromis(_ promis: [PromiItem], by option: PromiFieldSortOption, doneSegment: Bool) -> [PromiItem] {
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

private enum PromiListSegment {
    case active
    case done
}

private struct PromiListRowCard: View {
    let promi: PromiItem
    let languageCode: String
    let onOpen: () -> Void
    let onToggleDone: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 14) {
                header
                titleBlock
                footer
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            statusDot

            VStack(alignment: .leading, spacing: 2) {
                Text(kindLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.54))

                if let assignee = promi.assignee, !assignee.isEmpty {
                    Text(assignee)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.black.opacity(0.42))
                }
            }

            Spacer()

            Button(action: onToggleDone) {
                HStack(spacing: 8) {
                    Image(systemName: promi.status == .done ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))

                    Text(promi.status == .done ? "Rouvrir" : "Valider")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(promi.status == .done ? Color.black.opacity(0.66) : .white)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(
                    Capsule(style: .continuous)
                        .fill(promi.status == .done ? Color.white.opacity(0.52) : Color(red: 0.21, green: 0.30, blue: 0.44))
                )
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var statusDot: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 11, height: 11)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.74), lineWidth: 1.2)
            )
    }

    @ViewBuilder
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(fullPromiTitle)
                .font(.system(size: 24, weight: .light))
                .foregroundColor(Color.black.opacity(0.84))
                .multilineTextAlignment(.leading)

            Text(importanceLabel)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.black.opacity(0.46))
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 5) {
                Text(secondaryDateLabelTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.40))

                Text(formattedDate(secondaryDate))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.black.opacity(0.66))
            }

            Spacer()

            intensityPill
        }
    }

    @ViewBuilder
    private var intensityPill: some View {
        HStack(spacing: 6) {
            ForEach(0..<dotCount, id: \.self) { _ in
                Circle()
                    .fill(Color.black.opacity(0.66))
                    .frame(width: 5, height: 5)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 26)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.54))
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(Color.white.opacity(0.54))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.78), lineWidth: 1)
            )
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
        case .precise:
            return "Précis"
        case .floating:
            return "En l’air"
        case .emotional:
            return "Émotionnel"
        }
    }

    private var importanceLabel: String {
        switch promi.importance {
        case .low:
            return "Importance douce"
        case .normal:
            return "Importance normale"
        case .urgent:
            return "Importance forte"
        }
    }

    private var secondaryDateLabelTitle: String {
        promi.status == .done ? "Accompli" : "Échéance"
    }

    private var secondaryDate: Date {
        if promi.status == .done {
            return promi.completedAt ?? promi.createdAt
        }
        return promi.dueDate
    }

    private var statusColor: Color {
        if promi.status == .done {
            return Color(red: 0.28, green: 0.72, blue: 0.52)
        }

        if promi.intensity >= 70 {
            return Color(red: 0.98, green: 0.37, blue: 0.27)
        } else if promi.intensity >= 40 {
            return Color(red: 0.27, green: 0.78, blue: 0.77)
        } else {
            return Color(red: 0.23, green: 0.31, blue: 0.48)
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
