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

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    @State private var titleSuffix = ""
    @State private var dueDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    @State private var assignee = ""
    @State private var intensity = 50
    @State private var selectedKind: PromiKind = .precise
    @State private var showValidationAnimation = false
    @State private var showExitConfirmation = false

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
                        titleField
                        kindSelector

                        if selectedKind == .precise {
                            dateBlock
                        } else {
                            floatingBlock
                        }

                        recipientBlock
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
                dismiss()
            }
            Button(cancelButtonTitle, role: .cancel) { }
        }
    }

    // MARK: - Confirmation dialog labels

    private var dialogTitle: String {
        isEnglish ? "Save as draft?" : "Sauvegarder en brouillon ?"
    }

    private var saveDraftButtonTitle: String {
        isEnglish ? "Save draft" : "Sauvegarder"
    }

    private var discardButtonTitle: String {
        isEnglish ? "Discard" : "Supprimer"
    }

    private var cancelButtonTitle: String {
        isEnglish ? "Cancel" : "Annuler"
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
            attributed[range].foregroundColor = brandOrange
        }
        return Text(attributed)
    }

    private var closeButton: some View {
        Button(action: handleClose) {
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
            sectionLabel(isEnglish ? "What do you promise" : "Ce que tu promets")

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Promi")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(brandOrange)

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
                    .tint(brandOrange)
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

            HStack(spacing: 8) {
                kindChip(
                    kind: .precise,
                    title: isEnglish ? "Precise" : "Précis"
                )
                kindChip(
                    kind: .floating,
                    title: isEnglish ? "In the air" : "En l’air"
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
            sectionLabel(isEnglish ? "When" : "Quand")

            HStack {
                DatePicker(
                    "",
                    selection: $dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(brandOrange)
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

    // MARK: - Recipient block

    private var recipientBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "For whom" : "Pour qui")

            TextField(
                "",
                text: $assignee,
                prompt: Text(isEnglish ? "Someone…" : "Quelqu’un…")
                    .foregroundColor(Color.white.opacity(0.36))
            )
            .textInputAutocapitalization(.words)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color.white.opacity(0.92))
            .tint(brandOrange)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(chromeCard(radius: 16))
        }
    }

    // MARK: - Intensity block

    private var intensityBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "Intensity" : "Intensité")

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
            Text(isEnglish ? "Create Promi" : "Créer ce Promi")
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
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private var createButtonBackground: some View {
        let enabled = !cleanSuffix.isEmpty
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(enabled ? brandOrange.opacity(0.86) : Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        enabled ? brandOrange.opacity(0.60) : Color.white.opacity(0.10),
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
        draftStore.saveDraft(draft)
    }

    private func createPromi() {
        guard !cleanSuffix.isEmpty else { return }

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

        let newPromi = PromiItem(
            title: cleanTitle,
            dueDate: effectiveDueDate,
            importance: intensity > 70 ? .urgent : (intensity > 40 ? .normal : .low),
            assignee: cleanAssignee.isEmpty ? nil : cleanAssignee,
            intensity: intensity,
            kind: selectedKind
        )

        promiStore.addPromi(newPromi)

        withAnimation(.easeOut(duration: 0.28)) {
            showValidationAnimation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            dismiss()
        }
    }
}
