//
//  ContactPickerView.swift
//  Promi
//
//  Sheet réutilisable pour sélectionner un ou plusieurs PromiContact.
//  Utilisé par AddPromiView (POUR QUI) et CreateNuéeView (AVEC QUI).
//
//  Mode hybride : si une liste de "membres prioritaires" est fournie
//  (ex. les membres d'une Nuée déjà sélectionnée plus haut dans le
//  formulaire), ils apparaissent en haut sous un séparateur "Dans
//  cette Nuée", suivis de tous les autres contacts triés par récence.
//
//  Multi-select : l'utilisateur peut cocher plusieurs contacts. Le
//  binding `selection` retourne les ids choisis. La création de
//  nouveaux contacts à la volée se fait via le champ texte en bas.
//

import SwiftUI

struct ContactPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var contactsStore: ContactsStore

    // Sélection courante (ids). Binding pour que le parent récupère
    // la sélection au moment où l'utilisateur ferme le sheet.
    @Binding var selection: Set<String>

    // IDs prioritaires affichés en haut sous "Dans cette Nuée".
    // Vide = pas de priorisation, tous les contacts sont mélangés.
    let priorityContactIds: [String]

    // Titre du sheet (ex. "Pour qui ?" / "Avec qui ?").
    let title: String

    @State private var query: String = ""
    @State private var newContactName: String = ""
    @FocusState private var newContactFieldFocused: Bool

    private var isFrench: Bool {
        !userStore.selectedLanguage.lowercased().starts(with: "fr")
    }

    // MARK: - Filtered & grouped data

    private var allFilteredContacts: [PromiContact] {
        contactsStore.contacts(matching: query)
    }

    private var prioritySection: [PromiContact] {
        guard !priorityContactIds.isEmpty else { return [] }
        let prioritySet = Set(priorityContactIds)
        return allFilteredContacts
            .filter { prioritySet.contains($0.id) }
            // On garde l'ordre des priorityContactIds (= ordre des
            // membres dans la Nuée), pas le tri par récence
            .sorted { a, b in
                let ai = priorityContactIds.firstIndex(of: a.id) ?? .max
                let bi = priorityContactIds.firstIndex(of: b.id) ?? .max
                return ai < bi
            }
    }

    private var otherSection: [PromiContact] {
        let prioritySet = Set(priorityContactIds)
        return allFilteredContacts.filter { !prioritySet.contains($0.id) }
    }

    private var canAddNewContact: Bool {
        let trimmed = newContactName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        // Empêche les doublons exacts (case-insensitive) avec un contact
        // existant. Si match, le bouton "+" devient "sélectionner" implicite.
        return !contactsStore.contacts.contains {
            $0.displayName.compare(trimmed, options: .caseInsensitive) == .orderedSame
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, 12)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 14)

                searchField
                    .padding(.horizontal, 22)
                    .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if !prioritySection.isEmpty {
                            sectionHeader(isFrench ? "Dans cette Nuée" : "In this Nuée")
                            VStack(spacing: 6) {
                                ForEach(prioritySection) { contact in
                                    contactRow(contact, isPriority: true)
                                }
                            }

                            if !otherSection.isEmpty {
                                sectionHeader(isFrench ? "Tous tes contacts" : "All your contacts")
                                    .padding(.top, 8)
                            }
                        } else if !otherSection.isEmpty && contactsStore.contacts.count > 0 {
                            sectionHeader(isFrench ? "Tes contacts" : "Your contacts")
                        }

                        VStack(spacing: 6) {
                            ForEach(otherSection) { contact in
                                contactRow(contact, isPriority: false)
                            }
                        }

                        if allFilteredContacts.isEmpty && !query.isEmpty {
                            emptyResultMessage
                                .padding(.top, 24)
                        }

                        if contactsStore.contacts.isEmpty && query.isEmpty {
                            emptyStateMessage
                                .padding(.top, 32)
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 22)
                }

                // Champ d'ajout de nouveau contact, fixé en bas.
                addContactBar
                    .padding(.horizontal, 22)
                    .padding(.bottom, 18)
                    .padding(.top, 8)
                    .background(
                        Color.black.opacity(0.92)
                            .overlay(
                                Rectangle()
                                    .fill(Color.white.opacity(0.06))
                                    .frame(height: 0.6),
                                alignment: .top
                            )
                    )
            }

            closeButton
                .padding(.trailing, 20)
                .padding(.top, 16)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .light))
                .foregroundColor(Color.white.opacity(0.94))

            Text(isFrench
                 ? "Sélectionne ou ajoute des personnes"
                 : "Pick or add people")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.52))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.42))

            TextField(
                isFrench ? "Rechercher" : "Search",
                text: $query
            )
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.white.opacity(0.92))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
        )
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.0)
            .foregroundColor(Color.white.opacity(0.46))
            .padding(.leading, 4)
    }

    @ViewBuilder
    private func contactRow(_ contact: PromiContact, isPriority: Bool) -> some View {
        let isSelected = selection.contains(contact.id)

        Button {
            Haptics.shared.lightTap()
            toggle(contact)
        } label: {
            HStack(spacing: 12) {
                // Pastille avec initiale
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? Brand.orange.opacity(0.86)
                                : Color.white.opacity(0.10)
                        )
                        .frame(width: 32, height: 32)
                    Text(initial(of: contact.displayName))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(
                            isSelected
                                ? Color.white.opacity(0.96)
                                : Color.white.opacity(0.62)
                        )
                }

                Text(contact.displayName)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.88))

                Spacer(minLength: 8)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Brand.orange.opacity(0.92))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                            ? Color.white.opacity(0.08)
                            : Color.white.opacity(0.03)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected
                            ? Brand.orange.opacity(0.42)
                            : (isPriority
                                ? Color.white.opacity(0.18)
                                : Color.white.opacity(0.08)),
                        lineWidth: isSelected ? 1.0 : 0.6
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var addContactBar: some View {
        HStack(spacing: 10) {
            TextField(
                isFrench ? "Ajouter un nouveau contact" : "Add a new contact",
                text: $newContactName
            )
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.white.opacity(0.94))
            .focused($newContactFieldFocused)
            .submitLabel(.done)
            .onSubmit { addNewContact() }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 0.6)
            )

            Button {
                addNewContact()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(
                        canAddNewContact
                            ? Brand.orange.opacity(0.92)
                            : Color.white.opacity(0.28)
                    )
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.05)))
                    .overlay(
                        Circle().stroke(
                            canAddNewContact
                                ? Brand.orange.opacity(0.42)
                                : Color.white.opacity(0.10),
                            lineWidth: 0.6
                        )
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canAddNewContact)
        }
    }

    private var emptyResultMessage: some View {
        VStack(spacing: 6) {
            Text(isFrench ? "Aucun contact trouvé" : "No contact found")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.62))
            Text(isFrench
                 ? "Tu peux l'ajouter ci-dessous."
                 : "You can add it below.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.42))
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyStateMessage: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Color.white.opacity(0.34))

            Text(isFrench
                 ? "Aucun contact pour l'instant"
                 : "No contacts yet")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.62))

            Text(isFrench
                 ? "Ajoute ta première personne ci-dessous."
                 : "Add your first person below.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.42))
        }
        .frame(maxWidth: .infinity)
    }

    private var closeButton: some View {
        Button {
            Haptics.shared.lightTap()
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.86))
                Text(isFrench ? "OK" : "OK")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.92))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func toggle(_ contact: PromiContact) {
        if selection.contains(contact.id) {
            selection.remove(contact.id)
        } else {
            selection.insert(contact.id)
            // Mise à jour récence à chaque sélection (le contact remonte
            // en haut la prochaine fois qu'on ouvre le picker).
            contactsStore.touch(contact)
        }
    }

    private func addNewContact() {
        let trimmed = newContactName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Haptics.shared.tinyPop()
        let contact = contactsStore.upsertByName(trimmed)
        selection.insert(contact.id)
        newContactName = ""
        newContactFieldFocused = true
    }

    private func initial(of name: String) -> String {
        guard let firstChar = name.trimmingCharacters(in: .whitespaces).first else {
            return "?"
        }
        return String(firstChar).uppercased()
    }
}
