import SwiftUI

struct EditPromiView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var userStore: UserStore

    let promi: PromiItem

    @State private var titleSuffix: String
    @State private var dueDate: Date
    @State private var assignee: String
    @State private var intensity: Int
    @State private var showValidationAnimation = false
    @State private var showDeleteConfirmation = false

    init(promi: PromiItem) {
        self.promi = promi
        _titleSuffix = State(initialValue: promi.editorSuffix)
        _dueDate = State(initialValue: promi.dueDate)
        _assignee = State(initialValue: promi.assignee ?? "")
        _intensity = State(initialValue: promi.intensity)
    }

    private var titleText: String {
        userStore.selectedLanguage.starts(with: "en") ? "Edit your Promi" : "Modifie ton Promi"
    }

    private var buttonText: String {
        if promi.status == .open {
            return userStore.selectedLanguage.starts(with: "en") ? "Mark as done" : "Marquer terminé"
        } else {
            return userStore.selectedLanguage.starts(with: "en") ? "Reopen" : "Réouvrir"
        }
    }

    private var intensityQuestion: String {
        if userStore.selectedLanguage.starts(with: "en") {
            return "How badly do you want this Promi to happen?"
        } else if userStore.selectedLanguage.starts(with: "es") {
            return "¿Cuánto quieres cumplir este Promi?"
        } else {
            return "À quel point veux-tu tenir ce Promi ?"
        }
    }

    private var normalizedTitle: String {
        PromiItem.normalizedTitle(from: titleSuffix)
    }

    var body: some View {
        ZStack {
            userStore.selectedPalette.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.4))
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text(titleText.replacingOccurrences(of: "Promi", with: ""))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor.opacity(0.5))

                        Text("Promi")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Brand.orange.opacity(0.85))
                    }

                    Spacer()

                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .ultraLight))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.4))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Promi")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Brand.orange.opacity(0.88))

                            Text(
                                userStore.selectedLanguage.starts(with: "en")
                                ? "Edit the continuation after “Promi …”"
                                : "Modifie la suite après « Promi … »"
                            )
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.75))

                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Promi")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Brand.orange.opacity(0.90))

                                TextField(
                                    userStore.selectedLanguage.starts(with: "en")
                                    ? "I take you to the sea"
                                    : "je t’emmène à la mer",
                                    text: $titleSuffix,
                                    axis: .vertical
                                )
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                                .lineLimit(2...4)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white.opacity(0.30))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.08), lineWidth: 1)
                            )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "When" : "Quand")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor)

                            Text(
                                userStore.selectedLanguage.starts(with: "en")
                                ? "Keep the moment visible."
                                : "Garde le moment bien visible."
                            )
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.75))

                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accentColor(Brand.orange.opacity(0.85))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(Color.white.opacity(0.30))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.08), lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(userStore.selectedLanguage.starts(with: "en") ? "For whom" : "Pour qui")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(userStore.selectedPalette.textSecondaryColor)

                            Text(
                                userStore.selectedLanguage.starts(with: "en")
                                ? "Add the person concerned."
                                : "Ajoute la personne concernée."
                            )
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(userStore.selectedPalette.textSecondaryColor.opacity(0.75))

                            TextField(
                                userStore.selectedLanguage.starts(with: "en") ? "Someone..." : "Quelqu’un...",
                                text: $assignee
                            )
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(userStore.selectedPalette.textPrimaryColor)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white.opacity(0.30))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(userStore.selectedPalette.textPrimaryColor.opacity(0.08), lineWidth: 1)
                            )
                        }

                        MinimalIntensityGaugeView(
                            intensity: $intensity,
                            question: intensityQuestion,
                            textColor: userStore.selectedPalette.textSecondaryColor
                        )

                        Spacer(minLength: 140)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 16) {
                    Button(action: saveChanges) {
                        Text(userStore.selectedLanguage.starts(with: "en") ? "Save changes" : "Enregistrer")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Brand.orange.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Brand.orange.opacity(0.3), lineWidth: 0.8)
                            )
                    }

                    Button(action: toggleStatus) {
                        Text(buttonText)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Brand.orange.opacity(0.6))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }

            if showValidationAnimation {
                PinkyPromiseSlightSlapView(isPresented: $showValidationAnimation)
                    .transition(.opacity)
            }
        }
        .confirmationDialog("Supprimer ce Promi ?", isPresented: $showDeleteConfirmation) {
            Button(userStore.selectedLanguage.starts(with: "en") ? "Delete" : "Supprimer", role: .destructive) {
                promiStore.deletePromi(promi)
                dismiss()
            }
            Button(userStore.selectedLanguage.starts(with: "en") ? "Cancel" : "Annuler", role: .cancel) {}
        }
    }

    private func saveChanges() {
        var updatedPromi = promi
        updatedPromi.title = normalizedTitle
        updatedPromi.dueDate = dueDate
        updatedPromi.assignee = assignee.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : assignee.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedPromi.intensity = intensity

        promiStore.updatePromi(updatedPromi)

        Haptics.shared.success()
        dismiss()
    }

    private func toggleStatus() {
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
