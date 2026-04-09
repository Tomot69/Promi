import SwiftUI

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
    @State private var showValidationAnimation = false
    @State private var showDeleteConfirmation = false

    init(promi: PromiItem) {
        self.promi = promi
        _titleSuffix = State(initialValue: promi.editorSuffix)
        _dueDate = State(initialValue: promi.dueDate)
        _assignee = State(initialValue: promi.assignee ?? "")
        _intensity = State(initialValue: promi.intensity)
        _selectedKind = State(initialValue: promi.kind)
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
                PinkyPromiseSlightSlapView(isPresented: $showValidationAnimation)
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
                    Image(systemName: promi.status == .open
                         ? "checkmark"
                         : "arrow.uturn.backward")
                        .font(.system(size: 10, weight: .semibold))

                    Text(promi.status == .open
                         ? (isEnglish ? "Mark as done" : "Marquer terminé")
                         : (isEnglish ? "Reopen" : "Réouvrir"))
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color.white.opacity(0.72))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
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

        promiStore.updatePromi(updatedPromi)

        Haptics.shared.success()
        dismiss()
    }

    private func toggleStatus() {
        Haptics.shared.lightTap()

        if promi.status == .open {
            promiStore.markAsDone(promi)

            withAnimation(.easeOut(duration: 0.3)) {
                showValidationAnimation = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            promiStore.markAsOpen(promi)
            dismiss()
        }
    }
}
