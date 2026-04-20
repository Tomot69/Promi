import SwiftUI
import EventKit

// MARK: - EditPromiView
//
// Page "Modifier un Promi" accessible depuis la tap d'un Promi. Design chrome
// cohérent avec AddPromiView, PromiListView, DraftsView, KarmaView, SettingsView :
// PromiChromePageBackground (mood-aware) + cards chrome + accent orange sur
// "Promi" dans le titre et dans le prefix du champ texte. Les mêmes 3 sections
// (Promi / Quand / Pour qui) + gauge intensité que AddPromiView, plus deux
// actions supplémentaires dans le footer : bouton Enregistrer et bouton
// secondaire Marquer terminé / Réouvrir. Icône poubelle chrome dans le header
// pour supprimer, avec confirmation.

struct EditPromiView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var nuéeStore: NuéeStore
    @EnvironmentObject var karmaStore: KarmaStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    let promi: PromiItem

    @State private var titleSuffix: String
    @State private var dueDate: Date
    @State private var assignee: String
    @State private var intensity: Int
    @State private var selectedKind: PromiKind
    @State private var selectedNuéeId: UUID?
    @State private var showValidationAnimation = false
    @State private var showChallenge = false
    @State private var calendarAdded = false
    @State private var showComments = false
    @State private var showDeleteConfirmation = false

    init(promi: PromiItem) {
        self.promi = promi
        _titleSuffix = State(initialValue: promi.editorSuffix)
        _dueDate = State(initialValue: promi.dueDate)
        _assignee = State(initialValue: promi.assignee ?? "")
        _intensity = State(initialValue: promi.intensity)
        _selectedKind = State(initialValue: promi.kind)
        _selectedNuéeId = State(initialValue: promi.nuéeId)
    }

    // MARK: - Derived state

    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    private let brandOrange = Color(red: 0.98, green: 0.56, blue: 0.22)

    private var cleanSuffix: String {
        titleSuffix.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanAssignee: String {
        assignee.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedTitle: String {
        PromiItem.normalizedTitle(from: cleanSuffix)
    }

    private var canSave: Bool {
        !cleanSuffix.isEmpty
    }

    private var intensityQuestion: String {
        if isEnglish {
            return "How badly do you want this Promi to happen?"
        } else if userStore.selectedLanguage.starts(with: "es") {
            return "¿Cuánto quieres cumplir este Promi?"
        } else {
            return "À quel point veux-tu tenir ce Promi ?"
        }
    }

    private var titleString: String {
        isEnglish ? "Modify a Promi" : "Modifier un Promi"
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            PromiChromePageBackground(
                pack: currentPack,
                mood: currentMood,
                promis: promiStore.promis,
                languageCode: userStore.selectedLanguage
            )

            VStack(spacing: 0) {
                topHeader

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        promiSection
                        kindSection

                        // Le bloc qui suit le sélecteur dépend du kind :
                        //   .precise   → date picker uniquement
                        //   .emotional → date picker + indice relationnel
                        //   .floating  → pas de date, juste une explication
                        switch selectedKind {
                        case .precise:
                            whenSection
                        case .emotional:
                            linkedSection
                        case .floating:
                            floatingSection
                        }

                        forWhomSection
                        nuéeSection
                        intensitySection

                        Spacer(minLength: 16)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }

                footerActions
            }

            if showValidationAnimation {
                PromiKeptCelebrationView(
                    isPresented: $showValidationAnimation,
                    karmaPercentage: karmaStore.karmaState.percentage,
                    isFrench: !isEnglish,
                    totalKept: promiStore.promis.filter { $0.status == .done }.count
                )
                .transition(.opacity)
            }
        }
        .confirmationDialog(
            isEnglish ? "Delete this Promi?" : "Supprimer ce Promi ?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(isEnglish ? "Delete" : "Supprimer", role: .destructive) {
                Haptics.shared.success()
                promiStore.deletePromi(promi)
                dismiss()
            }
            Button(isEnglish ? "Cancel" : "Annuler", role: .cancel) {}
        }
        .sheet(isPresented: $showChallenge) {
            PublicChallengeView(promi: promi)
                .environmentObject(userStore)
        }
        .sheet(isPresented: $showComments) {
            CommentsView(promiId: promi.id)
                .environmentObject(promiStore)
                .environmentObject(userStore)
        }
    }

    // MARK: - Top header

    @ViewBuilder
    private var topHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                titleAttributed
                    .font(.system(size: 28, weight: .light))

                Text(isEnglish
                     ? "refine the promise you already made"
                     : "ajuste la promesse déjà posée")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.54))
            }

            Spacer()

            HStack(spacing: 10) {
                deleteButton
                closeButton
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    /// "Modifier un Promi" / "Modify a Promi" with "Promi" in brand orange.
    private var titleAttributed: Text {
        var attributed = AttributedString(titleString)
        attributed.foregroundColor = Color.white.opacity(0.94)

        if let range = attributed.range(of: "Promi") {
            attributed[range].foregroundColor = brandOrange
        }

        return Text(attributed)
    }

    private var deleteButton: some View {
        Button {
            Haptics.shared.lightTap()
            showDeleteConfirmation = true
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.78))
                .frame(width: 34, height: 34)
                .background(chromePillCircle)
        }
        .buttonStyle(.plain)
    }

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
            .background(chromePill)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section: Promi text field

    @ViewBuilder
    private var promiSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("PROMI")

            Text(isEnglish
                 ? "Edit the continuation after “Promi …”"
                 : "modifie la suite après « Promi … »")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Promi")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(brandOrange)

                TextField(
                    isEnglish ? "I take you to the sea" : "je t’emmène à la mer",
                    text: $titleSuffix,
                    axis: .vertical
                )
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white.opacity(0.92))
                .tint(brandOrange)
                .lineLimit(2...4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(chromeCard)
        }
    }

    // MARK: - Section: Kind selector (Précis / Lié / En l'air)

    @ViewBuilder
    private var kindSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "MODE" : "MODE")

            // Trois modes en gradient sémantique :
            //   gauche  : Précis  → ancrage technique, moment fixe
            //   centre  : Lié     → relationnel, moment ancré sur une personne
            //   droite  : En l'air → libre, sans moment, pure intention
            HStack(spacing: 8) {
                kindChip(.precise,    title: isEnglish ? "Precise" : "Précis")
                kindChip(.emotional,  title: isEnglish ? "Linked"  : "Lié")
                kindChip(.floating,   title: isEnglish ? "In the air" : "En l’air")
            }
        }
    }

    @ViewBuilder
    private func kindChip(_ kind: PromiKind, title: String) -> some View {
        let isSelected = selectedKind == kind

        Button {
            Haptics.shared.lightTap()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                selectedKind = kind
            }
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
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(isSelected ? 0.10 : 0.00))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            Color.white.opacity(isSelected ? 0.18 : 0.08),
                            lineWidth: 0.6
                        )
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section: Linked (.emotional — date + relational hint)

    @ViewBuilder
    private var linkedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel(isEnglish ? "WHEN" : "QUAND")

                Text(isEnglish
                     ? "the moment, attached to the person."
                     : "le moment, attaché à la personne.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.52))

                DatePicker(
                    "",
                    selection: $dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(brandOrange)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(chromeCard)
            }

            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(brandOrange.opacity(0.58))
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

    // MARK: - Section: Floating (.floating — pure intention, no date)

    @ViewBuilder
    private var floatingSection: some View {
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
        .background(chromeCard)
    }

    // MARK: - Section: When

    @ViewBuilder
    private var whenSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "WHEN" : "QUAND")

            Text(isEnglish
                 ? "keep the moment visible."
                 : "garde le moment bien visible.")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))

            DatePicker(
                "",
                selection: $dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .colorScheme(.dark)
            .tint(brandOrange)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(chromeCard)
        }
    }

    // MARK: - Section: For whom

    @ViewBuilder
    private var forWhomSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "FOR WHOM" : "POUR QUI")

            Text(isEnglish
                 ? "the person this Promi is for."
                 : "la personne concernée par ce Promi.")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))

            TextField(
                isEnglish ? "Someone…" : "quelqu’un…",
                text: $assignee
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color.white.opacity(0.92))
            .tint(brandOrange)
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(chromeCard)
        }
    }

    // MARK: - Section: Nuée (optional — attach this Promi to a Nuée)
    //
    // Horizontal scroll of chips. The first chip is always "Aucune"
    // (default selection — personal Promi, not attached to any group).
    // Each subsequent chip is one of the user's active Nuées, displayed
    // with its swatch dot, its icon, and its name. Tap to select.
    //
    // Editing existing membership: when this view opens with a Promi that
    // already has a `nuéeId`, the chip for that Nuée is preselected. The
    // user can change to another Nuée or to "Aucune" (which detaches the
    // Promi from any group). Saved on tap of the Save button.

    @ViewBuilder
    private var nuéeSection: some View {
        let userNuées = nuéeStore.activeNuées(for: userStore.localUserId)

        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "NUÉE" : "NUÉE")

            Text(isEnglish
                 ? "optional — attach to a shared swarm"
                 : "optionnel — rattacher à un essaim partagé")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))

            if userNuées.isEmpty {
                Text(isEnglish
                     ? "no Nuée yet · create one in the dock"
                     : "aucune Nuée pour l'instant · crées-en une dans la dock")
                    .font(.system(size: 12, weight: .regular))
                    .italic()
                    .foregroundColor(Color.white.opacity(0.46))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(chromeCard)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
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

    // MARK: - Section: Intensity

    @ViewBuilder
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "INTENSITY" : "INTENSITÉ")

            MinimalIntensityGaugeView(
                intensity: $intensity,
                question: intensityQuestion,
                textColor: Color.white.opacity(0.66)
            )
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(chromeCard)
        }
    }

    // MARK: - Footer (Save + Toggle status)

    @ViewBuilder
    private var footerActions: some View {
        VStack(spacing: 10) {
            Button(action: saveChanges) {
                Text(isEnglish ? "Save changes" : "Enregistrer")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.white.opacity(canSave ? 0.96 : 0.38))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    canSave
                                        ? brandOrange.opacity(0.86)
                                        : Color.white.opacity(0.06)
                                )
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    canSave
                                        ? Color.white.opacity(0.22)
                                        : Color.white.opacity(0.12),
                                    lineWidth: 0.6
                                )
                        }
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canSave)

           Button(action: toggleStatus) {
                HStack(spacing: 6) {
                    if promi.status == .open {
                        Text(isEnglish ? "I kept it" : "Tenu")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Brand.orange.opacity(0.88))
                    } else {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 10, weight: .semibold))
                        Text(isEnglish ? "Reopen" : "Réouvrir")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.58))
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            // Défi public — partager le Promi en story avec timer.
            if promi.status == .open {
                Button {
                    Haptics.shared.lightTap()
                    showChallenge = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(isEnglish ? "Public challenge" : "Défi public")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Brand.orange.opacity(0.82))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }

            // Ajouter au calendrier
            if promi.status == .open && !calendarAdded {
                Button {
                    addToCalendar()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 10, weight: .semibold))
                        Text(isEnglish ? "Add to Calendar" : "Ajouter au calendrier")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color.white.opacity(0.58))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            } else if calendarAdded {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                    Text(isEnglish ? "Added" : "Ajouté")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(red: 0.34, green: 0.80, blue: 0.60).opacity(0.72))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }

            // ── Social : Bravo + Commentaires ──
            VStack(spacing: 10) {
                HStack(spacing: 0) {
                    // Bravo
                    Button {
                        if !promiStore.hasBravo(promiId: promi.id, userId: userStore.localUserId) {
                            let bravo = Bravo(promiId: promi.id, userId: userStore.localUserId)
                            promiStore.addBravo(bravo)
                            Haptics.shared.success()
                        } else {
                            Haptics.shared.lightTap()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            PinkyPromiseGlyph(
                                isDarkField: true
                            )
                            .frame(width: 22, height: 22)
                            .opacity(promiStore.hasBravo(promiId: promi.id, userId: userStore.localUserId) ? 1.0 : 0.7)
                            Text(isEnglish ? "Bravo" : "Bravo")
                                .font(.system(size: 14, weight: .medium))
                            if promiStore.getBravosCount(for: promi.id) > 0 {
                                Text("\(promiStore.getBravosCount(for: promi.id))")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color.white.opacity(0.52))
                            }
                        }
                        .foregroundColor(
                            promiStore.hasBravo(promiId: promi.id, userId: userStore.localUserId)
                                ? Brand.orange
                                : Color.white.opacity(0.72)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(width: 10)

                    // Commentaires
                    Button {
                        Haptics.shared.lightTap()
                        showComments = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 18, weight: .medium))
                            Text(isEnglish ? "Comments" : "Commentaires")
                                .font(.system(size: 14, weight: .medium))
                            if promiStore.getCommentsCount(for: promi.id) > 0 {
                                Text("\(promiStore.getCommentsCount(for: promi.id))")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color.white.opacity(0.52))
                            }
                        }
                        .foregroundColor(Color.white.opacity(0.72))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    // MARK: - Chrome helpers

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

    private var chromePillCircle: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
            Circle()
                .fill(Color.black.opacity(0.22))
            Circle()
                .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
        }
    }

    // MARK: - Actions

    private func saveChanges() {
        guard canSave else { return }
        Haptics.shared.lightTap()

        var updatedPromi = promi
        updatedPromi.title = normalizedTitle
        updatedPromi.kind = selectedKind

        // For .floating, we keep the dueDate as a "soft" placeholder so the
        // sort logic can still order things — but the user's intent is that
        // it's not bound to that moment. If switching FROM another kind TO
        // .floating, we push the dueDate 90 days out so the Promi doesn't
        // sit at the top of the list with an obsolete moment.
        if selectedKind == .floating && promi.kind != .floating {
            updatedPromi.dueDate =
                Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? dueDate
        } else {
            updatedPromi.dueDate = dueDate
        }

        let trimmedAssignee = cleanAssignee
        updatedPromi.assignee = trimmedAssignee.isEmpty ? nil : trimmedAssignee
        updatedPromi.intensity = intensity
        updatedPromi.nuéeId = selectedNuéeId

        promiStore.updatePromi(updatedPromi)

        Haptics.shared.success()
        dismiss()
    }

    private func addToCalendar() {
        let store = EKEventStore()
        store.requestFullAccessToEvents { granted, error in
            guard granted, error == nil else { return }
            let event = EKEvent(eventStore: store)
            event.title = "Promi: \(promi.title)"
            event.startDate = promi.dueDate
            event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: promi.dueDate)
            event.notes = promi.assignee.map { "Pour \($0)" }
            event.calendar = store.defaultCalendarForNewEvents
            event.addAlarm(EKAlarm(relativeOffset: -3600)) // 1h avant
            do {
                try store.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    Haptics.shared.success()
                    calendarAdded = true
                }
            } catch {
                print("[Promi] Calendar save error: \(error)")
            }
        }
    }

    private func toggleStatus() {
        if promi.status == .open {
            // Haptic satisfaisante : ronronnement court puis success
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
            // Deuxième micro-vibration décalée pour le "ronronnement"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred(intensity: 0.6)
            }

            promiStore.markAsDone(promi)
                        karmaStore.updateKarma(basedOn: promiStore.promis)
                        karmaStore.recordPromiKept()
                        NotificationManager.shared.cancelReminders(for: promi.id)
            NotificationManager.shared.updateBadge(promis: promiStore.promis)
                        Haptics.shared.success()
                        Haptics.shared.playKeptSound()
            // Bonus karma minuit : mettre à jour immédiatement
            karmaStore.updateKarma(basedOn: promiStore.promis)

            withAnimation(.easeOut(duration: 0.3)) {
                showValidationAnimation = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                dismiss()
            }
        } else {
            Haptics.shared.lightTap()
            promiStore.markAsOpen(promi)
            // Reprogrammer les rappels — le Promi est rouvert.
            NotificationManager.shared.scheduleReminders(
                for: promi, language: userStore.selectedLanguage
            )
            dismiss()
        }
    }
}
