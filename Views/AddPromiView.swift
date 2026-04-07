import SwiftUI

struct AddPromiView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var draftStore: DraftStore

    @State private var titleSuffix = ""
    @State private var dueDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    @State private var assignee = ""
    @State private var intensity = 50
    @State private var selectedKind: PromiKind = .precise
    @State private var showValidationAnimation = false
    @State private var showExitConfirmation = false

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
            Color(red: 0.96, green: 0.955, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
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
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
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

    private var dialogTitle: String {
        userStore.selectedLanguage.starts(with: "en") ? "Save as draft?" : "Sauvegarder en brouillon ?"
    }

    private var saveDraftButtonTitle: String {
        userStore.selectedLanguage.starts(with: "en") ? "Save draft" : "Sauvegarder"
    }

    private var discardButtonTitle: String {
        userStore.selectedLanguage.starts(with: "en") ? "Discard" : "Supprimer"
    }

    private var cancelButtonTitle: String {
        userStore.selectedLanguage.starts(with: "en") ? "Cancel" : "Annuler"
    }

    private var header: some View {
        HStack {
            Button(action: handleClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.black.opacity(0.68))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(userStore.selectedLanguage.starts(with: "en") ? "Create a Promi" : "Créer un Promi")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black.opacity(0.84))

            Spacer()

            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 18)
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(userStore.selectedLanguage.starts(with: "en") ? "Promi" : "Promi")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.orange.opacity(0.92))

            Text(
                userStore.selectedLanguage.starts(with: "en")
                ? "Complete your sentence after “Promi …”"
                : "Complète ta phrase après « Promi … »"
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.black.opacity(0.44))

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Promi")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color.orange.opacity(0.88))

                // ZStack: TextField avec placeholder vide (le curseur démarre
                // exactement après "Promi") + Text placeholder personnalisé
                // affiché tant que le buffer est vide.
                ZStack(alignment: .topLeading) {
                    if titleSuffix.isEmpty {
                        Text(
                            userStore.selectedLanguage.starts(with: "en")
                            ? "I take you to the sea"
                            : "je t’emmène à la mer"
                        )
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black.opacity(0.32))
                        .allowsHitTesting(false)
                    }

                    TextField(
                        "",
                        text: $titleSuffix,
                        axis: .vertical
                    )
                    .textInputAutocapitalization(.sentences)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.black.opacity(0.90))
                    .lineLimit(1...4)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.34))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
    }

    private var kindSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mode")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.56))

            HStack(spacing: 10) {
                kindChip(kind: .precise, title: userStore.selectedLanguage.starts(with: "en") ? "Precise" : "Précis")
                kindChip(kind: .floating, title: userStore.selectedLanguage.starts(with: "en") ? "In the air" : "En l’air")
            }
        }
    }

    private func kindChip(kind: PromiKind, title: String) -> some View {
        Button {
            selectedKind = kind
            Haptics.shared.lightTap()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selectedKind == kind ? .medium : .regular))
                .foregroundColor(selectedKind == kind ? .black.opacity(0.88) : .black.opacity(0.56))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(selectedKind == kind ? Color.orange.opacity(0.20) : Color.white.opacity(0.24))
                )
                .overlay(
                    Capsule()
                        .stroke(selectedKind == kind ? Color.orange.opacity(0.40) : Color.black.opacity(0.07), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var dateBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(userStore.selectedLanguage.starts(with: "en") ? "When" : "Quand")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.56))

            Text(
                userStore.selectedLanguage.starts(with: "en")
                ? "Set the moment clearly."
                : "Précise le moment clairement."
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.black.opacity(0.42))

            HStack {
                DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.black.opacity(0.82))

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
    }

    private var floatingBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Promi en l’air")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.86))

            Text(
                userStore.selectedLanguage.starts(with: "en")
                ? "It stays open, light, and untied to a strict time."
                : "Il reste ouvert, léger, et non attaché à un moment strict."
            )
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.black.opacity(0.56))
            .lineSpacing(3)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.orange.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.orange.opacity(0.20), lineWidth: 1)
        )
    }

    private var recipientBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(userStore.selectedLanguage.starts(with: "en") ? "For whom" : "Pour qui")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.56))

            Text(
                userStore.selectedLanguage.starts(with: "en")
                ? "Add the person concerned."
                : "Ajoute la personne concernée."
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.black.opacity(0.42))

            TextField(
                userStore.selectedLanguage.starts(with: "en") ? "Someone..." : "Quelqu’un...",
                text: $assignee
            )
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black.opacity(0.84))
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
    }

    private var intensityBlock: some View {
        MinimalIntensityGaugeView(
            intensity: $intensity,
            question: userStore.selectedLanguage.starts(with: "en")
                ? "How much presence should it carry?"
                : "Quelle présence doit-il porter ?",
            textColor: .black.opacity(0.62)
        )
    }

    private var createButton: some View {
        Button(action: createPromi) {
            Text(userStore.selectedLanguage.starts(with: "en") ? "Create Promi" : "Créer ce Promi")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(cleanSuffix.isEmpty ? .black.opacity(0.28) : .black.opacity(0.86))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(cleanSuffix.isEmpty ? Color.white.opacity(0.20) : Color.orange.opacity(0.20))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(cleanSuffix.isEmpty ? Color.black.opacity(0.06) : Color.orange.opacity(0.42), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(cleanSuffix.isEmpty)
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 28)
    }

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
