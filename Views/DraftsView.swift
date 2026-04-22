import SwiftUI

// MARK: - DraftsView
//
// Unified drafts page showing both Promi drafts and Nuée drafts in
// two sections. Accessible from the "+" dropdown menu in the dock.
// Design chrome cohérent : mood home background + ultraThinMaterial.

struct DraftsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var draftStore: DraftStore
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

    @State private var editingPromiDraft: PromiDraft?
    @State private var editingNuéeDraft: NuéeDraft?

    private var isEnglish: Bool {
        userStore.selectedLanguage.lowercased().starts(with: "en")
    }
    @State private var pendingDeletePromi: PromiDraft?
    @State private var pendingDeleteNuée: NuéeDraft?

    private var isEmpty: Bool {
        draftStore.drafts.isEmpty && draftStore.nuéeDrafts.isEmpty
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

                VStack(spacing: 0) {
                    topHeader

                    if isEmpty {
                        emptyState
                    } else {
                        draftList
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $editingPromiDraft) { d in AddPromiView(editingDraft: d) }
            .sheet(item: $editingNuéeDraft) { d in CreateNuéeView(editingDraft: d) }
            .confirmationDialog(isEnglish ? "Discard this draft?" : "Jeter ce brouillon ?", isPresented: Binding(get: { pendingDeletePromi != nil || pendingDeleteNuée != nil }, set: { if !$0 { pendingDeletePromi = nil; pendingDeleteNuée = nil } }), titleVisibility: .visible) {
                Button(isEnglish ? "Discard" : "Jeter", role: .destructive) {
                    if let d = pendingDeletePromi { withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) { draftStore.deleteDraft(d) }; pendingDeletePromi = nil }
                    if let d = pendingDeleteNuée { withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) { draftStore.deleteNuéeDraft(d) }; pendingDeleteNuée = nil }
                }
                Button(isEnglish ? "Cancel" : "Annuler", role: .cancel) { pendingDeletePromi = nil; pendingDeleteNuée = nil }
            }
        }
    }

    // MARK: - Header

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
            }

            Spacer()

            closeButton
                .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }

    private var titleAttributed: Text {
        let total = draftStore.totalDraftCount
        let prefix: String
        let suffix: String
        if isEnglish {
            prefix = total == 1 ? "My " : "My "
            suffix = total == 1 ? "Draft" : "Drafts"
        } else {
            prefix = total == 1 ? "Mon " : "Mes "
            suffix = total == 1 ? "Brouillon" : "Brouillons"
        }
        var attributed = AttributedString(prefix + suffix)
        attributed.foregroundColor = Color.white.opacity(0.94)
        if let range = attributed.range(of: suffix) {
            attributed[range].foregroundColor = Brand.orange
        }
        return Text(attributed)
    }

    private var dynamicSubtitle: String {
        let p = draftStore.drafts.count
        let n = draftStore.nuéeDrafts.count
        if p == 0 && n == 0 {
            return isEnglish ? "nothing pending" : "rien en attente"
        }
        var parts: [String] = []
        if p > 0 { parts.append("\(p) Promi\(p > 1 ? "s" : "")") }
        if n > 0 { parts.append("\(n) Nuée\(n > 1 ? "s" : "")") }
        return parts.joined(separator: " · ")
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

                Text(isEnglish ? "Close" : "Fermer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.94))
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(chromePill)
        }
        .buttonStyle(.plain)
    }

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

    // MARK: - Draft list (two sections)

    @ViewBuilder
    private var draftList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Promi drafts section
                if !draftStore.drafts.isEmpty {
                    sectionHeader(
                        title: "PROMI",
                        icon: "text.badge.plus",
                        count: draftStore.drafts.count
                    )

                    ForEach(draftStore.drafts) { draft in
                        PromiDraftCard(
                            draft: draft,
                            languageCode: userStore.selectedLanguage,
                            onTap: { Haptics.shared.lightTap(); editingPromiDraft = draft },
                            onDelete: { Haptics.shared.tinyPop(); pendingDeletePromi = draft }
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                }

                // Nuée drafts section
                if !draftStore.nuéeDrafts.isEmpty {
                    sectionHeader(
                        title: "NUÉES",
                        icon: "circle.hexagongrid",
                        count: draftStore.nuéeDrafts.count
                    )

                    ForEach(draftStore.nuéeDrafts) { draft in
                        NuéeDraftCard(
                            draft: draft,
                            languageCode: userStore.selectedLanguage,
                            onTap: { Haptics.shared.lightTap(); editingNuéeDraft = draft },
                            onDelete: { Haptics.shared.tinyPop(); pendingDeleteNuée = draft }
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 28)
        }
    }

    @ViewBuilder
    private func sectionHeader(title: String, icon: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Brand.orange.opacity(0.78))

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.48))
                .tracking(1.0)

            Text("\(count)")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.40))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 10)
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

                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(Color.white.opacity(0.68))
                }

                Text(isEnglish ? "No drafts" : "Aucun brouillon")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(Color.white.opacity(0.88))

                Text(isEnglish
                     ? "Promis and Nuées started without saving are kept here."
                     : "Les Promis et Nuées commencés sans validation sont conservés ici.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Promi draft card

private struct PromiDraftCard: View {
    let draft: PromiDraft
    let languageCode: String
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Brand.orange.opacity(0.48))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.90))
                    .lineLimit(2)

                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
            }

            Spacer(minLength: 0)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color.white.opacity(0.42))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
        }
    }

    private var title: String {
        let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Promi sans titre" : trimmed
    }

    private var subtitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageCode.isEmpty ? "fr_FR" : languageCode)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Créé le \(formatter.string(from: draft.createdAt))"
    }
}

// MARK: - Nuée draft card

private struct NuéeDraftCard: View {
    let draft: NuéeDraft
    let languageCode: String
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Swatch dot — uses the draft's chosen palette color if any,
            // otherwise a neutral teal.
            Circle()
                .fill(swatchColor.opacity(0.58))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.90))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: draft.kind.defaultIconGlyph)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.48))

                    Text(kindLabel)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.52))

                    Text("·")
                        .foregroundColor(Color.white.opacity(0.30))

                    Text(subtitle)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.44))
                }
            }

            Spacer(minLength: 0)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color.white.opacity(0.42))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
        }
    }

    private var swatchColor: Color {
        NuéePalette.color(fromHex: draft.moodHintRawValue)
            ?? Color(red: 0.28, green: 0.72, blue: 0.76)
    }

    private var title: String {
        let trimmed = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Nuée sans nom" : trimmed
    }

    private var kindLabel: String {
        switch draft.kind {
        case .thematic: return "Thématique"
        case .intimate: return "Intime"
        }
    }

    private var subtitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageCode.isEmpty ? "fr_FR" : languageCode)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: draft.createdAt)
    }
}
