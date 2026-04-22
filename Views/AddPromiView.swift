import SwiftUI

// MARK: - AddPromiView
//
// Page "Créer un Promi" accessible depuis le dropdown du bouton "+". Design
// chrome cohérent avec les menus tri et "+", et les pages Mes/Mon Promi,
// Brouillons, Karma : mood home background + ultraThinMaterial + dark tint.
// Le mot "Promi" dans le champ et dans les accents est en orange.

struct AddPromiView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var draftStore: DraftStore
    @EnvironmentObject var nuéeStore: NuéeStore
    @EnvironmentObject var contactsStore: ContactsStore
    @EnvironmentObject var karmaStore: KarmaStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    let editingDraft: PromiDraft?
    let preselectedNuéeId: UUID?

    @State private var titleSuffix: String
    @State private var dueDate: Date
    @State private var assignee: String
    @State private var intensity: Int

    init(editingDraft: PromiDraft? = nil, preselectedNuéeId: UUID? = nil) {
        self.editingDraft = editingDraft
        self.preselectedNuéeId = preselectedNuéeId
        let stripped: String = {
            guard let t = editingDraft?.title else { return "" }
            let trimmed = t.trimmingCharacters(in: .whitespaces)
            if trimmed.lowercased().hasPrefix("promi ") {
                return String(trimmed.dropFirst(6))
            }
            return trimmed
        }()
        _titleSuffix = State(initialValue: stripped)
        _dueDate = State(initialValue: editingDraft?.dueDate ?? (Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()))
        _assignee = State(initialValue: editingDraft?.assignee ?? "")
        _intensity = State(initialValue: editingDraft?.intensity ?? 50)
        _selectedNuéeId = State(initialValue: preselectedNuéeId)
    }
    @State private var selectedKind: PromiKind = .precise
    @State private var selectedNuéeId: UUID?
    @State private var showValidationAnimation = false
    @State private var showExitConfirmation = false

    // Sélection multi-destinataires structurée (Phase 6). Ouvre
    // ContactPickerView en sheet. L'ancien champ texte `assignee` est
    // conservé et rempli automatiquement avec les noms concaténés
    // pour la rétrocompat (display, draft, save).
    @State private var selectedRecipientIds: Set<String> = []
    @State private var showRecipientPicker = false
    @State private var showPaywall = false

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "fr")
    }


    private var cleanSuffix: String {
        titleSuffix.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanAssignee: String {
        assignee.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanTitle: String {
        PromiItem.normalizedTitle(from: cleanSuffix)
    }

    private var hasDraftableContent: Bool {
        !cleanSuffix.isEmpty || !cleanAssignee.isEmpty
    }

    var body: some View {
        ZStack {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        // Promi est social par vocation. L'info la plus
                        // importante après le contenu ("ce que tu promets"),
                        // c'est à qui la promesse s'adresse. Donc POUR QUI
                        // remonte en 2e position, juste sous le titre, avant
                        // le mode/date qui sont des précisions techniques.
                        titleField
                        recipientBlock
                        kindSelector

                        // Le bloc qui suit le sélecteur dépend du kind :
                        //   .precise   → date picker uniquement (moment fixe)
                        //   .emotional → date picker + indice relationnel
                        //                ("Lié" = la relation prime sur l'horaire)
                        //   .floating  → pas de date, juste une explication
                        //                ("En l'air" = pure intention)
                        switch selectedKind {
                        case .precise:
                            dateBlock
                        case .emotional:
                            linkedBlock
                        case .floating:
                            floatingBlock
                        }

                        nuéeBlock
                        intensityBlock

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 16)
                }

                createButton
            }

            if showValidationAnimation {
                PromiValidationAnimationView(isPresented: $showValidationAnimation)
                    .transition(.opacity)
            }
        }
        .confirmationDialog(dialogTitle, isPresented: $showExitConfirmation) {
            Button(saveDraftButtonTitle) {
                saveDraft()
                dismiss()
            }
            Button(discardButtonTitle, role: .destructive) {
                if let d = editingDraft { draftStore.deleteDraft(d) }
                dismiss()
            }
            Button(cancelButtonTitle, role: .cancel) { }
        }
    }

    // MARK: - Confirmation dialog labels

    private var dialogTitle: String {
        Loc.saveDraftQ
    }

    private var saveDraftButtonTitle: String {
        Loc.saveDraft
    }

    private var discardButtonTitle: String {
        Loc.discard
    }

    private var cancelButtonTitle: String {
        Loc.cancel
    }

    // MARK: - Header with orange "Promi" accent

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                titleAttributed
                    .font(.system(size: 28, weight: .light))

                Text(isEnglish ? "a clear promise, a set moment" : "une promesse claire, un moment fixé")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))
                    .tracking(0.2)
            }

            Spacer()

            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 18)
    }

    /// Title: "Nouveau " in near-white + "Promi" in brand orange.
    private var titleAttributed: Text {
        let prefix = isEnglish ? "New " : "Nouveau "
        var attributed = AttributedString(prefix + "Promi")
        attributed.foregroundColor = Color.white.opacity(0.94)
        if let range = attributed.range(of: "Promi") {
            attributed[range].foregroundColor = Brand.orange
        }
        return Text(attributed)
    }

    private var closeButton: some View {
        Button(action: handleClose) {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.82))

                Text(Loc.close)
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

    // MARK: - Title field (Promi + inline typing)

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(Loc.whatDoYouPromise)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Promi")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Brand.orange)

                ZStack(alignment: .topLeading) {
                    if titleSuffix.isEmpty {
                        Text(
                            isEnglish
                            ? "I take you to the sea sunday"
                            : "je t’emmène à la mer dimanche"
                        )
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.32))
                        .allowsHitTesting(false)
                    }

                    TextField(
                        "",
                        text: $titleSuffix,
                        axis: .vertical
                    )
                    .textInputAutocapitalization(.sentences)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.94))
                    .tint(Brand.orange)
                    .lineLimit(1...4)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(chromeCard(radius: 18))
        }
    }

    // MARK: - Kind selector (Précis / En l'air)

    private var kindSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "Mode" : "Mode")

            // Trois modes, ordonnés en gradient sémantique :
            //   gauche  : Précis  → ancrage technique, moment fixe
            //   centre  : Lié     → relationnel, moment ancré sur une personne
            //   droite  : En l'air → libre, sans moment, pure intention
            HStack(spacing: 8) {
                kindChip(
                    kind: .precise,
                    title: Loc.precise
                )
                kindChip(
                    kind: .emotional,
                    title: Loc.linked
                )
                kindChip(
                                    kind: .floating,
                                    title: Loc.inTheAir
                                )
            }
        }
    }

    private func kindChip(kind: PromiKind, title: String) -> some View {
        let isSelected = selectedKind == kind
        return Button {
            selectedKind = kind
            Haptics.shared.lightTap()
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.96) : Color.white.opacity(0.26))
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.96 : 0.68))
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

    // MARK: - Date block (precise Promi)

    private var dateBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(Loc.when)

            HStack {
                DatePicker(
                    "",
                    selection: $dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(Brand.orange)
                .colorScheme(.dark)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(chromeCard(radius: 16))
        }
    }

    // MARK: - Floating block (non-precise Promi)

    private var floatingBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isEnglish ? "Promi in the air" : "Promi en l’air")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.88))

            Text(
                isEnglish
                ? "It stays open, light, untied to a strict time."
                : "Il reste ouvert, léger, non attaché à un moment strict."
            )
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(Color.white.opacity(0.58))
            .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(chromeCard(radius: 16))
    }

    // MARK: - Linked block (.emotional Promi: date + relational hint)
    //
    // A "Lié" Promi a une date, comme un Promi précis, mais le sens
    // produit est différent : c'est une promesse ANCRÉE à une personne,
    // où la relation prime sur la rigueur de l'horaire. Le date picker
    // est donc présent (tu peux dire "samedi matin"), mais on souligne
    // visuellement que la dimension émotionnelle est centrale.

    private var linkedBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel(Loc.when)

                HStack {
                    DatePicker(
                        "",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Brand.orange)
                    .colorScheme(.dark)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(chromeCard(radius: 16))
            }

            // Relational hint — visually anchored under the date to make
            // explicit that "Lié" is about the relationship, not the clock.
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(Brand.orange.opacity(0.58))
                    .frame(width: 4, height: 4)
                    .padding(.top, 6)

                Text(
                    isEnglish
                    ? "A linked Promi belongs to a person before it belongs to a moment. The clock matters; the bond matters more."
                    : "Un Promi lié appartient d’abord à une personne, ensuite à un moment. L’heure compte ; le lien compte davantage."
                )
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.62))
                .italic()
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Recipient block

    private var recipientBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(Loc.forWhom)

            Button {
                Haptics.shared.lightTap()
                showRecipientPicker = true
            } label: {
                HStack(spacing: 10) {
                    if selectedRecipientIds.isEmpty {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.42))
                        Text(Loc.someone)
                                                    .font(.system(size: 16, weight: .regular))
                                                    .foregroundColor(Color.white.opacity(0.36))
                    } else {
                        // Pastilles d'initiales empilées + résumé textuel.
                        recipientAvatarStack
                        Text(recipientSummary)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.92))
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.42))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(chromeCard(radius: 16))
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showPaywall) {
            PromiPlusPaywallView()
                .environmentObject(userStore)
                .environmentObject(promiStore)
        }
        .sheet(isPresented: $showRecipientPicker) {
            ContactPickerView(
                selection: $selectedRecipientIds,
                priorityContactIds: priorityContactIdsForPicker,
                title: Loc.forWhomQ
            )
            .environmentObject(userStore)
            .environmentObject(contactsStore)
        }
    }

    /// Membres de la Nuée actuellement sélectionnée (mode hybride : ils
    /// remontent en haut du picker). Vide si pas de Nuée choisie ou si
    /// aucun membre n'est dans le ContactsStore.
    private var priorityContactIdsForPicker: [String] {
        guard let nuéeId = selectedNuéeId,
              let nuée = nuéeStore.nuée(with: nuéeId)
        else { return [] }
        // On filtre les members de la Nuée qui ont un ID match dans le
        // ContactsStore. Pour les nouveaux contacts ajoutés via Nuée
        // (Phase 6), l'ID Nuée membre = l'ID PromiContact.
        let memberIds = Set(nuée.members.map(\.id))
        return contactsStore.contactsByRecency
            .filter { memberIds.contains($0.id) }
            .map(\.id)
    }

    /// Vue empilée de pastilles avec initiales pour les destinataires
    /// sélectionnés. Limite à 3 pastilles + "+N" si plus.
    private var recipientAvatarStack: some View {
        let recipients = selectedRecipients.prefix(3)
        let extra = max(0, selectedRecipients.count - 3)
        return HStack(spacing: -8) {
            ForEach(Array(recipients.enumerated()), id: \.element.id) { _, contact in
                ZStack {
                    Circle()
                        .fill(Brand.orange.opacity(0.86))
                        .frame(width: 24, height: 24)
                    Circle()
                        .stroke(Color.black.opacity(0.38), lineWidth: 1)
                        .frame(width: 24, height: 24)
                    Text(initial(of: contact.displayName))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.96))
                }
            }
            if extra > 0 {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 24, height: 24)
                    Text("+\(extra)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.86))
                }
            }
        }
    }

    /// Résumé texte des destinataires : "Léo", "Léo & Maman", "Léo +2".
    private var recipientSummary: String {
        let names = selectedRecipients.map(\.displayName)
        switch names.count {
        case 0: return ""
        case 1: return names[0]
        case 2: return "\(names[0]) & \(names[1])"
        default: return "\(names[0]) +\(names.count - 1)"
        }
    }

    /// PromiContact correspondant à `selectedRecipientIds`, dans l'ordre
    /// du tri par récence (= ordre cohérent avec ce qu'on voit dans le picker).
    private var selectedRecipients: [PromiContact] {
        contactsStore.contactsByRecency.filter { selectedRecipientIds.contains($0.id) }
    }

    private func initial(of name: String) -> String {
        guard let firstChar = name.trimmingCharacters(in: .whitespaces).first else {
            return "?"
        }
        return String(firstChar).uppercased()
    }

    // MARK: - Nuée block (optional — attach this Promi to a Nuée)
    //
    // Horizontal scroll of chips. The first chip is always "Aucune"
    // (default selection — personal Promi, not attached to any group).
    // Each subsequent chip is one of the user's active Nuées, displayed
    // with its swatch dot, its icon, and its name. Tap to select.
    //
    // The selected Nuée's id is stored in `selectedNuéeId` and persisted
    // on the new PromiItem at creation time. If no Nuée is selected, the
    // Promi is personal (`nuéeId == nil`) and won't show a halo on the
    // home Voronoï.

    private var nuéeBlock: some View {
        let userNuées = nuéeStore.activeNuées(for: userStore.localUserId)

        return VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "Nuée" : "Nuée")

            Text(isEnglish
                 ? "optional — attach to a shared swarm"
                 : "optionnel — rattacher à un essaim partagé")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))

            if userNuées.isEmpty {
                // No Nuée yet — show a hint instead of an empty scroll.
                Text(isEnglish
                     ? "no Nuée yet · create one in the dock"
                     : "aucune Nuée pour l'instant · crées-en une dans la dock")
                    .font(.system(size: 12, weight: .regular))
                    .italic()
                    .foregroundColor(Color.white.opacity(0.46))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(chromeCard(radius: 16))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // "Aucune" chip — always first, default selection
                        nuéeChip(
                            isSelected: selectedNuéeId == nil,
                            label: isEnglish ? "None" : "Aucune",
                            iconGlyph: nil,
                            swatchHex: nil
                        ) {
                            Haptics.shared.lightTap()
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                                selectedNuéeId = nil
                            }
                        }

                        ForEach(userNuées) { nuée in
                            nuéeChip(
                                isSelected: selectedNuéeId == nuée.id,
                                label: nuée.name,
                                iconGlyph: nuée.displayIconGlyph,
                                swatchHex: nuée.moodHintRawValue
                            ) {
                                Haptics.shared.lightTap()
                                withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                                    selectedNuéeId = nuée.id
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    @ViewBuilder
    private func nuéeChip(
        isSelected: Bool,
        label: String,
        iconGlyph: String?,
        swatchHex: String?,
        action: @escaping () -> Void
    ) -> some View {
        let swatchColor = NuéePalette.color(fromHex: swatchHex)

        Button(action: action) {
            HStack(spacing: 8) {
                // Swatch dot or empty circle for "Aucune"
                if let swatch = swatchColor {
                    Circle()
                        .fill(swatch)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.32), lineWidth: 0.6)
                        )
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.42), lineWidth: 0.8)
                        .frame(width: 10, height: 10)
                }

                if let iconGlyph {
                    Image(systemName: iconGlyph)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.white.opacity(isSelected ? 0.96 : 0.66))
                }

                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(Color.white.opacity(isSelected ? 0.96 : 0.68))
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(isSelected ? 0.10 : 0.04))
                    Capsule(style: .continuous)
                        .stroke(
                            Color.white.opacity(isSelected ? 0.24 : 0.10),
                            lineWidth: isSelected ? 1.0 : 0.6
                        )
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Intensity block

    private var intensityBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(Loc.intensity)

            MinimalIntensityGaugeView(
                intensity: $intensity,
                question: isEnglish
                    ? "How much presence should it carry?"
                    : "Quelle présence doit-il porter ?",
                textColor: Color.white.opacity(0.66)
            )
            .padding(16)
            .background(chromeCard(radius: 16))
        }
    }

    // MARK: - Create button (orange accent, disabled when empty)

    private var createButton: some View {
        Button(action: createPromi) {
            Text(Loc.createPromi)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(
                    cleanSuffix.isEmpty
                    ? Color.white.opacity(0.32)
                    : Color.white.opacity(0.96)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(createButtonBackground)
        }
        .buttonStyle(.plain)
        .disabled(cleanSuffix.isEmpty)
        .accessibilityLabel(isEnglish ? "Create Promi" : "Créer le Promi")
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private var createButtonBackground: some View {
        let enabled = !cleanSuffix.isEmpty
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(enabled ? Brand.orange.opacity(0.86) : Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        enabled ? Brand.orange.opacity(0.60) : Color.white.opacity(0.10),
                        lineWidth: 0.6
                    )
            )
    }

    // MARK: - Shared chrome helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(Color.white.opacity(0.48))
            .tracking(1.0)
    }

    @ViewBuilder
    private func chromeCard(radius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white.opacity(0.05))

            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
        }
    }

    // MARK: - Actions

    private func handleClose() {
        if hasDraftableContent {
            showExitConfirmation = true
        } else {
            dismiss()
        }
    }

    private func saveDraft() {
        let draft = PromiDraft(
            title: cleanTitle,
            dueDate: dueDate,
            assignee: cleanAssignee.isEmpty ? nil : cleanAssignee,
            intensity: intensity
        )
        var d = draft
        if let existing = editingDraft { d = PromiDraft(id: existing.id, title: draft.title, dueDate: draft.dueDate, assignee: draft.assignee, intensity: draft.intensity, createdAt: existing.createdAt) }
        draftStore.saveDraft(d)
    }

    private func createPromi() {
        guard !cleanSuffix.isEmpty else { return }

        // Quota free tier : vérification avant création.
        guard userStore.canCreatePromi else {
            Haptics.shared.lightTap()
            showPaywall = true
            return
        }

        let effectiveDueDate: Date = {
            switch selectedKind {
            case .precise:
                return dueDate
            case .floating:
                return Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
            case .emotional:
                return dueDate
            }
        }()

        // Pour rétrocompat : on remplit aussi le champ `assignee` legacy
        // avec un résumé texte des noms structurés. Comme ça les vieux
        // écrans qui lisent `assignee` continuent d'afficher quelque chose.
        let recipientNames = contactsStore.contactsByRecency
            .filter { selectedRecipientIds.contains($0.id) }
            .map(\.displayName)
        let assigneeFallback: String? = {
            if !recipientNames.isEmpty {
                return recipientNames.joined(separator: ", ")
            }
            return cleanAssignee.isEmpty ? nil : cleanAssignee
        }()

        // Touche les contacts sélectionnés pour les remonter en récence.
        for id in selectedRecipientIds {
            if let c = contactsStore.contact(id: id) {
                contactsStore.touch(c)
            }
        }

        var newPromi = PromiItem(
            title: cleanTitle,
            dueDate: effectiveDueDate,
            importance: intensity > 70 ? .urgent : (intensity > 40 ? .normal : .low),
            assignee: assigneeFallback,
            intensity: intensity,
            kind: selectedKind,
            nuéeId: selectedNuéeId,
            recipientContactIds: Array(selectedRecipientIds)
        )
        
        // Easter egg : Promi de minuit (00:00–00:05)
                let hour = Calendar.current.component(.hour, from: Date())
                let minute = Calendar.current.component(.minute, from: Date())
        if hour == 0 && minute < 5 {
                    newPromi.isMidnightPromi = true
                    NotificationManager.shared.scheduleMidnightCelebration(
                        promiTitle: newPromi.title,
                        language: userStore.selectedLanguage
                    )
                }
        
        let isFirst = promiStore.promis.isEmpty
        promiStore.addPromi(newPromi)
        if isFirst {
            Haptics.shared.success()
        }
        karmaStore.updateKarma(basedOn: promiStore.promis)
        userStore.recordPromiCreation()
        NotificationManager.shared.scheduleReminders(
            for: newPromi,
            language: userStore.selectedLanguage
        )
        
        withAnimation(.easeOut(duration: 0.28)) {
            showValidationAnimation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            dismiss()
        }
    }
}
