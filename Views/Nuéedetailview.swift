//
//  NuéeDetailView.swift
//  Promi
//
//  Phase 2 — Nuée detail page, presented from MesNuéesView.
//

import SwiftUI

// MARK: - NuéeDetailView
//
// Page détail d'une Nuée. Affiche son nom, son icône, son sous-titre
// dynamique, ses membres, et la liste des Promis qui lui appartiennent.
// Boutons d'action en bas : Quitter (pour les membres) ou Supprimer
// (pour le créateur).
//
// Phase 2 = lecture + suppression. La création de Promis attachés à
// la Nuée arrive en Phase 3 (modification d'AddPromiView pour accepter
// un paramètre `nuéeId`).
//
// Le design utilise une approche "ID-based" pour observer le store : on
// passe juste un nuéeId au constructeur, puis on récupère la Nuée fraîche
// à chaque body render via le NuéeStore. Comme ça, si la Nuée est modifiée
// (membres, expiration), la vue se rafraîchit automatiquement.

struct NuéeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var promiStore: PromiStore
    @EnvironmentObject var nuéeStore: NuéeStore
    @EnvironmentObject var contactsStore: ContactsStore
    @EnvironmentObject var draftStore: DraftStore
    @EnvironmentObject var karmaStore: KarmaStore

    @AppStorage("promi.visualPack")
    private var visualPackRawValue: String = PromiVisualPack.alveolesSignature.rawValue

    @AppStorage("promi.visualMood")
    private var visualMoodRawValue: String = PromiColorMood.terrePromi.rawValue

    let nuéeId: UUID

    @State private var showDeleteConfirmation = false
    @State private var showLeaveConfirmation = false
    @State private var showAddPromi = false
    @State private var showCreateThematic = false


    private var currentPack: PromiVisualPack {
        PromiVisualPack(rawValue: visualPackRawValue) ?? .alveolesSignature
    }

    /// The page chrome uses the user's CURRENT global mood — the Nuée's
    /// own signature color is used only for tinting its identity elements
    /// (icon badge, member avatars, promi row dots). This keeps the
    /// PromiChromePageBackground consistent with the rest of the app
    /// while letting each Nuée carry its own visual personality on top.
    private var currentMood: PromiColorMood {
        PromiColorMood(rawValue: visualMoodRawValue) ?? .terrePromi
    }

    private var isEnglish: Bool {
        userStore.selectedLanguage.starts(with: "en")
    }

    private var currentNuée: Nuée? {
        nuéeStore.nuée(with: nuéeId)
    }

    private var nuéePromis: [PromiItem] {
        promiStore.promis
            .filter { $0.nuéeId == nuéeId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var isCreator: Bool {
        currentNuée?.creatorId == userStore.localUserId
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

            if let nuée = currentNuée {
                content(for: nuée)
            } else {
                missingNuéeState
            }

            closeButton
                .padding(.trailing, 20)
                .padding(.top, 16)
        }
        .sheet(item: $selectedChildNuée) { child in
            // Drill-down dans la sous-thématique : même NuéeDetailView
            // qui s'ouvre récursivement. La vue affichera les Promis de
            // cette thématique, sans la section Thématiques (puisque
            // child.kind == .thematic, la condition `if nuée.kind == .intimate`
            // sera false).
            NuéeDetailView(nuéeId: child.id)
        }
        .sheet(isPresented: $showAddPromi) {
            // Promi pré-attaché à cette Nuée. Le champ NUÉE sera déjà
            // sélectionné sur cette Nuée, pas besoin de le chercher.
            AddPromiView(preselectedNuéeId: nuéeId)
        }
        .sheet(isPresented: $showCreateThematic) {
            CreateNuéeView(
                parentNuéeId: nuéeId,
                preselectedKind: .thematic,
                preselectedMemberIds: memberIdsForThematic
            )
        }
        .confirmationDialog(
            isEnglish ? "Delete this Nuée?" : "Supprimer cette Nuée ?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(isEnglish ? "Delete" : "Supprimer", role: .destructive) {
                if let nuée = currentNuée {
                    Haptics.shared.success()
                    nuéeStore.delete(nuée)
                    dismiss()
                }
            }
            Button(isEnglish ? "Cancel" : "Annuler", role: .cancel) {}
        } message: {
            Text(isEnglish
                 ? "All shared Promis will lose their Nuée link. This cannot be undone."
                 : "Tous les Promis partagés perdront leur lien à la Nuée. Cette action est irréversible.")
        }
        .confirmationDialog(
            isEnglish ? "Leave this Nuée?" : "Quitter cette Nuée ?",
            isPresented: $showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button(isEnglish ? "Leave" : "Quitter", role: .destructive) {
                Haptics.shared.lightTap()
                nuéeStore.removeMember(userId: userStore.localUserId, from: nuéeId)
                dismiss()
            }
            Button(isEnglish ? "Cancel" : "Annuler", role: .cancel) {}
        }
    }

    // MARK: Content

    @ViewBuilder
    private func content(for nuée: Nuée) -> some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    nuéeHeader(nuée)
                    membersSection(nuée)
                    if nuée.kind == .intimate {
                        thematicsSection
                    }
                    karmaSection(nuée)
                    promisSection
                    contextActions(for: nuée)
                    if nuée.isExpired {
                        archivedNotice
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 22)
                .padding(.top, 70)     // space for floating close button
                .padding(.bottom, 24)
            }

            footerActions(for: nuée)
        }
    }

    // MARK: Header

    @ViewBuilder
    private func nuéeHeader(_ nuée: Nuée) -> some View {
        let badgeColor = NuéePalette.color(fromHex: nuée.moodHintRawValue) ?? Brand.orange

        HStack(alignment: .center, spacing: 14) {
            // Big icon badge — uses the Nuée's own swatch color for
            // identity. The SF Symbol matches CreateNuéeView's kind
            // cards for visual cohérence across the app:
            //   .thematic → "tag"
            //   .intimate → "lock.heart"
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(badgeColor.opacity(0.28))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(badgeColor.opacity(0.48), lineWidth: 0.6)

                Image(systemName: nuée.displayIconGlyph)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color.white.opacity(0.96))
                    .shadow(color: badgeColor.opacity(0.36), radius: 4, x: 0, y: 1)
            }
            .frame(width: 62, height: 62)

            VStack(alignment: .leading, spacing: 4) {
                Text(nuée.name)
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(Color.white.opacity(0.96))
                    .lineLimit(2)

                Text(nuée.localizedSubtitle(isEnglish: isEnglish))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.58))
            }

            Spacer()
        }
    }

    // MARK: Theme block (if any)

    @ViewBuilder
    private func themeBlock(_ theme: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(isEnglish ? "THEME" : "THÈME")

            Text(theme)
                .font(.system(size: 14, weight: .regular))
                .italic()
                .foregroundColor(Color.white.opacity(0.78))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(chromeCard)
        }
    }

    // MARK: Members section

    @ViewBuilder
    private func membersSection(_ nuée: Nuée) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(isEnglish ? "MEMBERS" : "MEMBRES")

            if let theme = nuée.theme, !theme.isEmpty {
                themeBlock(theme)
                    .padding(.bottom, 4)
            }

            VStack(spacing: 0) {
                ForEach(Array(nuée.members.enumerated()), id: \.element.id) { index, member in
                    memberRow(member, isCreator: member.id == nuée.creatorId)

                    if index < nuée.members.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 0.6)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(chromeCard)
        }
    }

    @ViewBuilder
    private func memberRow(_ member: NuéeMember, isCreator: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Brand.orange.opacity(0.28))
                Circle()
                    .stroke(Brand.orange.opacity(0.42), lineWidth: 0.6)

                Text(initials(from: member.displayName))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.96))
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.displayName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.92))

                if isCreator {
                    Text(isEnglish ? "creator" : "créateur·ice")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Brand.orange.opacity(0.86))
                }
            }

            Spacer()

            if !member.hasAccepted {
                Text(isEnglish ? "pending" : "en attente")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.6)
                    .foregroundColor(Color.white.opacity(0.46))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let initials = parts.compactMap { $0.first }.map(String.init).joined()
        return initials.uppercased().isEmpty ? "?" : initials.uppercased()
    }

    // MARK: Promis section

    // MARK: Karma podium (pré-CloudKit : seulement soi-même)

    @ViewBuilder
    private func karmaSection(_ nuée: Nuée) -> some View {
        let karma = karmaStore.karmaState.percentage
        let displayName = userStore.displayName

        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("KARMA")

            HStack(spacing: 14) {
                // Position
                Text("1")
                    .font(.system(size: 18, weight: .light, design: .monospaced))
                    .foregroundColor(Brand.orange.opacity(0.82))
                    .frame(width: 24)

                // Avatar
                ZStack {
                    Circle()
                        .fill(karmaColor(karma).opacity(0.72))
                        .frame(width: 32, height: 32)
                    Text(String(displayName.prefix(1)).uppercased())
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.92))
                }

                // Nom + score
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.88))
                    Text("\(karma)%")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(karmaColor(karma).opacity(0.82))
                }

                Spacer()

                // Badge rang
                Text(karmaRank(karma, isFrench: !isEnglish))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.58))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(karmaColor(karma).opacity(0.16))
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(chromeCard)
        }
    }

    private func karmaColor(_ karma: Int) -> Color {
        if karma >= 90 { return Brand.karmaExcellent }
        else if karma >= 70 { return Brand.karmaGood }
        else if karma >= 50 { return Brand.karmaAverage }
        else { return Brand.karmaPoor }
    }

    private func karmaRank(_ karma: Int, isFrench: Bool) -> String {
        if karma >= 90 { return isFrench ? "signature" : "signature" }
        else if karma >= 70 { return isFrench ? "fiable" : "reliable" }
        else if karma >= 50 { return isFrench ? "variable" : "variable" }
        else { return isFrench ? "à prouver" : "to prove" }
    }

    // MARK: Child thematics (Intime only)

    private var thematicsSection: some View {
        let children = nuéeStore.childNuées(of: nuéeId)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                sectionLabel(isEnglish ? "THEMATICS" : "THÉMATIQUES")
                Spacer()
                if !children.isEmpty {
                    Text("\(children.count)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.62))
                }
            }

            if children.isEmpty {
                Text(isEnglish
                     ? "no thematic yet — create one below"
                     : "aucune thématique — crée-en une ci-dessous")
                    .font(.system(size: 12, weight: .regular))
                    .italic()
                    .foregroundColor(Color.white.opacity(0.46))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(chromeCard)
            } else {
                VStack(spacing: 8) {
                    ForEach(children) { child in
                        thematicRow(child)
                    }
                }
            }
        }
    }

    @State private var selectedChildNuée: Nuée?

    @ViewBuilder
    private func thematicRow(_ child: Nuée) -> some View {
        let childPromis = promiStore.promis.filter { $0.nuéeId == child.id }
        let badgeColor = NuéePalette.color(fromHex: child.moodHintRawValue) ?? Brand.orange

        Button {
            Haptics.shared.lightTap()
            selectedChildNuée = child
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(badgeColor.opacity(0.72))
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(child.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.92))
                    if let theme = child.theme, !theme.isEmpty {
                        Text(theme)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.46))
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text("\(childPromis.count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.52))

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.34))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(chromeCard)
        }
        .buttonStyle(.plain)
    }

    private var promisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                sectionLabel(isEnglish ? "PROMIS" : "PROMIS")
                Spacer()
                Text("\(nuéePromis.count)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.62))
            }

            if nuéePromis.isEmpty {
                Text(isEnglish
                     ? "no Promi in this Nuée yet"
                     : "aucun Promi dans cette Nuée pour l’instant")
                    .font(.system(size: 12, weight: .regular))
                    .italic()
                    .foregroundColor(Color.white.opacity(0.46))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(chromeCard)
            } else {
                VStack(spacing: 8) {
                    ForEach(nuéePromis) { promi in
                        nuéePromiRow(promi)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func nuéePromiRow(_ promi: PromiItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(Brand.orange.opacity(0.62))
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if promi.status == .done {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Brand.karmaGood.opacity(0.82))
                    }
                    Text(promi.title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white.opacity(promi.status == .done ? 0.72 : 0.92))
                        .lineLimit(2)
                }

                if let assignee = promi.assignee, !assignee.isEmpty {
                    Text(isEnglish ? "for \(assignee)" : "pour \(assignee)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.46))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(chromeCard)
    }

    // MARK: Context actions (add Promi, create thematic)

    @ViewBuilder
    private func contextActions(for nuée: Nuée) -> some View {
        if !nuée.isExpired {
            VStack(spacing: 10) {
                // Toutes les Nuées : ajouter un Promi pré-attaché.
                Button {
                    Haptics.shared.lightTap()
                    showAddPromi = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Brand.orange.opacity(0.86))
                        Text(isEnglish
                             ? "Add a Promi to this Nuée"
                             : "Ajouter un Promi à cette Nuée")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.88))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.38))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Brand.orange.opacity(0.08))
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Brand.orange.opacity(0.28), lineWidth: 0.6)
                        }
                    )
                }
                .buttonStyle(.plain)

                // Nuées Intimes seulement : créer une thématique dans le
                // cercle intime, pré-remplie avec les membres du groupe.
                if nuée.kind == .intimate {
                    Button {
                        Haptics.shared.lightTap()
                        showCreateThematic = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "circle.hexagongrid.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.72))
                            Text(isEnglish
                                 ? "Create a thematic for this group"
                                 : "Créer une thématique pour ce groupe")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.88))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.38))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.14), lineWidth: 0.6)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Archived notice

    private var archivedNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "archivebox")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white.opacity(0.62))

            Text(isEnglish
                 ? "This Nuée has expired. Its Promis are read-only."
                 : "Cette Nuée a expiré. Ses Promis sont en lecture seule.")
                .font(.system(size: 12, weight: .regular))
                .italic()
                .foregroundColor(Color.white.opacity(0.62))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(chromeCard)
    }

    // MARK: Footer actions

    @ViewBuilder
    private func footerActions(for nuée: Nuée) -> some View {
        VStack(spacing: 10) {
            if isCreator {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 11, weight: .semibold))
                        Text(isEnglish ? "Delete the Nuée" : "Supprimer la Nuée")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(Color.white.opacity(0.78))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
                        }
                    )
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    showLeaveConfirmation = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                        Text(isEnglish ? "Leave the Nuée" : "Quitter la Nuée")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(Color.white.opacity(0.78))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 0.6)
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    // MARK: Missing Nuée state (e.g. just deleted)

    private var missingNuéeState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "questionmark.circle")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(Color.white.opacity(0.58))

            Text(isEnglish
                 ? "This Nuée no longer exists"
                 : "Cette Nuée n’existe plus")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.white.opacity(0.62))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Close button

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

    /// Récupère les IDs des membres de la Nuée courante pour les
    /// pré-remplir dans le CreateNuéeView (thématique dans un cercle
    /// intime). Exclut le créateur (il sera ajouté automatiquement).
    private var memberIdsForThematic: Set<String> {
        guard let nuée = currentNuée else { return [] }
        return Set(
            nuée.members
                .filter { $0.id != userStore.localUserId }
                .map(\.id)
        )
    }

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
}
