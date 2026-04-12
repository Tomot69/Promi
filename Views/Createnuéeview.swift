//
//  CreateNuéeView.swift
//  Promi
//
//  Phase 2 — Nuée creation form, presented from MesNuéesView.
//

import SwiftUI

// MARK: - CreateNuéeView
//
// Form de création d'une Nuée, présenté en sheet depuis MesNuéesView.
// Une seule scrollview avec toutes les sections visibles, design chrome
// cohérent avec AddPromiView et toutes les autres pages.
//
// Sections :
//   1. Nom — champ texte obligatoire
//   2. Mode — chips Thématique / Intime
//   3. Thème — champ optionnel décrivant le sujet (plus utile pour .thematic)
//   4. Palette — grille 6×4 de 24 hex swatches couvrant tout le spectre
//   5. Durée — toggle Permanente / Éphémère + date centrée si éphémère
//   6. Bouton Créer la Nuée
//
// L'utilisateur courant est automatiquement ajouté comme premier membre
// (creator) avec hasAccepted=true. La gestion d'invitation des autres
// membres arrive en Phase 6.

struct CreateNuéeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var nuéeStore: NuéeStore
    @EnvironmentObject var draftStore: DraftStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    let editingDraft: NuéeDraft?

    @State private var name: String
    @State private var theme: String
    @State private var selectedKind: NuéeKind
    @State private var selectedSwatchHex: String
    @State private var isEphemeral: Bool
    @State private var expirationDate: Date
    @State private var showDraftConfirmation = false

    init(editingDraft: NuéeDraft? = nil) {
        self.editingDraft = editingDraft
        _name = State(initialValue: editingDraft?.name ?? "")
        _theme = State(initialValue: editingDraft?.theme ?? "")
        _selectedKind = State(initialValue: editingDraft?.kind ?? .thematic)
        _selectedSwatchHex = State(initialValue: editingDraft?.moodHintRawValue ?? NuéePalette.swatches[0].hex)
        _isEphemeral = State(initialValue: editingDraft?.expiresAt != nil)
        _expirationDate = State(initialValue: editingDraft?.expiresAt ?? (Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()))
    }


    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    private var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canCreate: Bool {
        !cleanName.isEmpty
    }

    /// True if the user has typed anything — triggers draft confirmation
    /// on close instead of silent dismiss.
    private var hasChanges: Bool {
        !cleanName.isEmpty || !theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 0) {
                topHeader

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        nameSection
                        kindSection
                        themeSection
                        moodSection
                        durationSection

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }

                createNuéeButton
            }

            closeButton
                .padding(.trailing, 20)
                .padding(.top, 16)
        }
        .interactiveDismissDisabled(hasChanges)
        .confirmationDialog(
            isEnglish ? "Save as draft?" : "Enregistrer comme brouillon ?",
            isPresented: $showDraftConfirmation,
            titleVisibility: .visible
        ) {
            Button(isEnglish ? "Save draft" : "Enregistrer le brouillon") {
                Haptics.shared.tinyPop()
                saveDraft()
            }
            Button(isEnglish ? "Discard" : "Jeter", role: .destructive) {
                if let d = editingDraft { draftStore.deleteNuéeDraft(d) }
                dismiss()
            }
            Button(isEnglish ? "Cancel" : "Annuler", role: .cancel) { }
        }
    }

    // MARK: Top header

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleAttributed
                .font(.system(size: 28, weight: .light))

            Text(isEnglish
                 ? "your shared swarm of Promis"
                 : "votre essaim de Promis partagé")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.54))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    private var titleAttributed: Text {
        let raw = isEnglish ? "New Nuée" : "Nouvelle Nuée"
        var attributed = AttributedString(raw)
        attributed.foregroundColor = Color.white.opacity(0.94)

        if let range = attributed.range(of: "Nuée") {
            attributed[range].foregroundColor = Brand.orange
        }

        return Text(attributed)
    }

    // MARK: Section: Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "NAME" : "NOM")

            TextField(
                isEnglish ? "e.g. Summer holidays 2026" : "ex. Vacances été 2026",
                text: $name
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color.white.opacity(0.92))
            .tint(Brand.orange)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(chromeCard)
        }
    }

    // MARK: Section: Kind (Thématique / Intime)

    private var kindSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "MODE" : "MODE")

            HStack(spacing: 10) {
                kindCard(
                    .thematic,
                    title: isEnglish ? "Thematic" : "Thématique",
                    subtitle: isEnglish
                        ? "around a topic"
                        : "autour d’un sujet"
                )
                kindCard(
                    .intimate,
                    title: isEnglish ? "Intimate" : "Intime",
                    subtitle: isEnglish
                        ? "a private inner circle"
                        : "un cercle privé"
                )
            }
        }
    }

    @ViewBuilder
    private func kindCard(
        _ kind: NuéeKind,
        title: String,
        subtitle: String
    ) -> some View {
        let isSelected = selectedKind == kind

        Button {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                selectedKind = kind
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: kind.defaultIconGlyph)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(
                        isSelected
                            ? Brand.orange.opacity(0.92)
                            : Color.white.opacity(0.62)
                    )

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.96 : 0.78))

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.66 : 0.46))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(isSelected ? 0.10 : 0.04))
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isSelected
                                ? Brand.orange.opacity(0.62)
                                : Color.white.opacity(0.12),
                            lineWidth: isSelected ? 1.0 : 0.6
                        )
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Section: Theme (optional)

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "THEME" : "THÈME")

            Text(isEnglish
                 ? "optional — what brings the Nuée together"
                 : "optionnel — ce qui réunit la Nuée")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))

            TextField(
                isEnglish ? "a sentence, a word, a vibe" : "une phrase, un mot, une vibe",
                text: $theme
            )
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.white.opacity(0.92))
            .tint(Brand.orange)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(chromeCard)
        }
    }

    // MARK: Section: Mood

    // MARK: Section: Palette

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "PALETTE" : "PALETTE")

            Text(isEnglish
                 ? "the visual vibe of the shared swarm"
                 : "la vibe visuelle de l’essaim partagé")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))

            // 24 hand-curated swatches arranged in a 6×4 grid. Each swatch
            // is a hex color stored on the Nuée; the palette spans the full
            // hue spectrum (warm reds → ochers → greens → teals → blues →
            // purples → pinks → neutrals) so the user can find a color that
            // truly matches the spirit of their group, instead of being
            // boxed into the 12 PromiColorMood gradients used elsewhere.
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6),
                spacing: 10
            ) {
                ForEach(NuéePalette.swatches, id: \.hex) { swatch in
                    swatchCircle(swatch)
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func swatchCircle(_ swatch: NuéeSwatch) -> some View {
        let isSelected = selectedSwatchHex == swatch.hex
        // Force unwrap is safe here: NuéePalette.swatches contains only
        // hand-curated 6-char hex literals defined statically in the same
        // file, so the parser cannot fail for any value in the loop.
        let color = NuéePalette.color(fromHex: swatch.hex) ?? Color.gray

        Button {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                selectedSwatchHex = swatch.hex
            }
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 38, height: 38)

                Circle()
                    .stroke(
                        isSelected
                            ? Color.white.opacity(0.96)
                            : Color.white.opacity(0.18),
                        lineWidth: isSelected ? 2.0 : 0.6
                    )
                    .frame(width: 38, height: 38)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.42), radius: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: Section: Duration

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "DURATION" : "DURÉE")

            HStack(spacing: 10) {
                durationToggle(
                    label: isEnglish ? "Permanent" : "Permanente",
                    selected: !isEphemeral
                ) {
                    Haptics.shared.lightTap()
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                        isEphemeral = false
                    }
                }
                durationToggle(
                    label: isEnglish ? "Ephemeral" : "Éphémère",
                    selected: isEphemeral
                ) {
                    Haptics.shared.lightTap()
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                        isEphemeral = true
                    }
                }
            }

            if isEphemeral {
                // Centered, minimal, slightly dramatic. No chrome card,
                // no left-aligned label, no padding box. Just two elements
                // floating in the center of the screen — the label "expire
                // le" and the date picker beneath it. The visual restraint
                // is what makes it feel weighty: the user sees an expiration
                // date as a small ceremony rather than as a form field.
                VStack(alignment: .center, spacing: 10) {
                    Text(isEnglish ? "expires on" : "expire le")
                        .font(.system(size: 11, weight: .regular))
                        .tracking(0.4)
                        .foregroundColor(Color.white.opacity(0.52))

                    HStack {
                        Spacer()
                        DatePicker(
                            "",
                            selection: $expirationDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .tint(Brand.orange)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 6)
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private func durationToggle(
        label: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: selected ? .semibold : .regular))
                .foregroundColor(Color.white.opacity(selected ? 0.96 : 0.68))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(selected ? 0.10 : 0.00))
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                Color.white.opacity(selected ? 0.18 : 0.08),
                                lineWidth: 0.6
                            )
                    }
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: Create Nuée button

    private var createNuéeButton: some View {
        Button(action: createNuée) {
            Text(isEnglish ? "Create the Nuée" : "Créer la Nuée")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.white.opacity(canCreate ? 0.96 : 0.38))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(canCreate ? Brand.orange.opacity(0.86) : Color.white.opacity(0.06))
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                canCreate ? Color.white.opacity(0.22) : Color.white.opacity(0.12),
                                lineWidth: 0.6
                            )
                    }
                )
        }
        .buttonStyle(.plain)
        .disabled(!canCreate)
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    // MARK: Close button

    private var closeButton: some View {
        Button {
            Haptics.shared.lightTap()
            if hasChanges {
                showDraftConfirmation = true
            } else {
                dismiss()
            }
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
            .foregroundColor(Color.white.opacity(0.48))
    }

    private var chromeCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
        }
    }

    // MARK: Action

    private func createNuée() {
        guard canCreate else { return }
        Haptics.shared.success()

        let creator = NuéeMember(
            id: userStore.localUserId,
            displayName: isEnglish ? "You" : "Vous",
            joinedAt: Date(),
            hasAccepted: true
        )

        let nuée = Nuée(
            name: cleanName,
            kind: selectedKind,
            theme: theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : theme.trimmingCharacters(in: .whitespacesAndNewlines),
            members: [creator],
            creatorId: userStore.localUserId,
            createdAt: Date(),
            expiresAt: isEphemeral ? expirationDate : nil,
            moodHintRawValue: selectedSwatchHex,
            iconGlyph: nil
        )

        nuéeStore.create(nuée)
        if let d = editingDraft { draftStore.deleteNuéeDraft(d) }
        dismiss()
    }

    private func saveDraft() {
        let draft = NuéeDraft(
            id: editingDraft?.id ?? UUID(),
            name: cleanName,
            kind: selectedKind,
            theme: theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : theme.trimmingCharacters(in: .whitespacesAndNewlines),
            moodHintRawValue: selectedSwatchHex,
            expiresAt: isEphemeral ? expirationDate : nil
        )
        draftStore.saveNuéeDraft(draft)
        dismiss()
    }
}
