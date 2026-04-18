import Foundation
import Combine

// MARK: - ContactsStore
//
// Répertoire local des personnes que l'utilisateur a déjà ajoutées dans
// au moins une Nuée ou un Promi. Sert de source unique pour les pickers
// "AVEC QUI" (Nuée) et "POUR QUI" (Promi).
//
// Architecture identique à NuéeStore (UserDefaults JSON), mais sans
// SyncBackend pour l'instant — les contacts restent strictement locaux
// jusqu'à ce que la sync sociale soit activée. Quand ce sera le cas,
// ce store gagnera un backend équivalent.

@MainActor
final class ContactsStore: ObservableObject {
    @Published var contacts: [PromiContact] = []

    /// IDs des Promi (PromiItem.id.uuidString) que l'utilisateur a
    /// individuellement masqués via long-press → "Masquer ce Promi".
    /// Indépendant du blocage de contact : on peut masquer un Promi
    /// sans bloquer son auteur. Réversible via showHiddenPromi().
    @Published var hiddenPromiIds: Set<String> = []

    private let userDefaults = UserDefaults.standard
    private let contactsKey = "promiContacts.v1"
    private let hiddenPromiIdsKey = "promiHiddenIds.v1"

    init() {
        loadContacts()
        loadHiddenPromiIds()
    }

    // MARK: - CRUD

    /// Ajoute un nouveau contact OU met à jour son lastUsedAt s'il existe
    /// déjà avec le même displayName (case-insensitive). Retourne le
    /// contact final (créé ou réutilisé). Idempotent.
    @discardableResult
    func upsertByName(_ displayName: String) -> PromiContact {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = contacts.first(where: {
            $0.displayName.compare(trimmed, options: .caseInsensitive) == .orderedSame
        }) {
            return touch(existing)
        }
        let new = PromiContact(displayName: trimmed)
        contacts.append(new)
        persistContacts()
        objectWillChange.send()
        return new
    }

    /// Ajoute un PromiContact préformé. Si un contact avec le même id
    /// existe déjà, met à jour son lastUsedAt sans dupliquer.
    @discardableResult
    func upsert(_ contact: PromiContact) -> PromiContact {
        if let idx = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[idx].lastUsedAt = Date()
            let updated = contacts[idx]
            persistContacts()
            objectWillChange.send()
            return updated
        }
        contacts.append(contact)
        persistContacts()
        objectWillChange.send()
        return contact
    }

    /// Met à jour le lastUsedAt d'un contact existant pour le faire
    /// remonter dans le tri par récence.
    @discardableResult
    func touch(_ contact: PromiContact) -> PromiContact {
        guard let idx = contacts.firstIndex(where: { $0.id == contact.id }) else {
            return contact
        }
        contacts[idx].lastUsedAt = Date()
        let updated = contacts[idx]
        persistContacts()
        objectWillChange.send()
        return updated
    }

    func remove(id: String) {
        contacts.removeAll { $0.id == id }
        persistContacts()
        objectWillChange.send()
    }

    func updateName(id: String, newName: String) {
        guard let idx = contacts.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        contacts[idx].displayName = trimmed
        contacts[idx].lastUsedAt = Date()
        persistContacts()
        objectWillChange.send()
    }

    // MARK: - Block / unblock contacts

    /// Bloque un contact existant. Si l'ID ne correspond à aucun contact
    /// connu, on en crée un automatiquement (cas d'un Promi reçu d'un
    /// utilisateur dont on n'a pas encore le contact en mémoire — peut
    /// arriver post-CloudKit quand un inconnu envoie un Promi via
    /// invitation Nuée).
    func blockContact(id: String, reason: String? = nil, fallbackName: String = "—") {
        if let idx = contacts.firstIndex(where: { $0.id == id }) {
            contacts[idx].blockedAt = Date()
            contacts[idx].blockReason = reason?.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // Contact inconnu : on en crée un blocked d'office.
            let newContact = PromiContact(
                id: id,
                displayName: fallbackName,
                blockedAt: Date(),
                blockReason: reason?.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            contacts.append(newContact)
        }
        persistContacts()
        objectWillChange.send()
    }

    /// Débloque un contact. Le contact reste dans la liste, ses Promi
    /// passés et futurs redeviennent visibles dans la home.
    func unblockContact(id: String) {
        guard let idx = contacts.firstIndex(where: { $0.id == id }) else { return }
        contacts[idx].blockedAt = nil
        contacts[idx].blockReason = nil
        persistContacts()
        objectWillChange.send()
    }

    /// Retourne tous les contacts actuellement bloqués, triés par date
    /// de blocage descendante (plus récents en haut). Sert à alimenter
    /// la liste "Utilisateurs bloqués" dans Settings.
    var blockedContacts: [PromiContact] {
        contacts
            .filter { $0.isBlocked }
            .sorted { ($0.blockedAt ?? .distantPast) > ($1.blockedAt ?? .distantPast) }
    }

    /// True si le contact identifié est bloqué. Utilisé par la home et
    /// par les pickers pour filtrer les Promi/contacts à afficher.
    func isBlocked(contactId: String) -> Bool {
        contacts.first { $0.id == contactId }?.isBlocked ?? false
    }

    /// True si le Promi est masqué (soit individuellement via hideShownPromi,
    /// soit parce que son expéditeur est bloqué). Source de vérité unique
    /// pour le filtrage de la home.
    func shouldHide(promi: PromiItem) -> Bool {
        if hiddenPromiIds.contains(promi.id.uuidString) { return true }
        if let senderId = promi.senderContactId, isBlocked(contactId: senderId) { return true }
        return false
    }

    // MARK: - Hide / show individual Promi

    /// Masque un Promi individuel sans bloquer son expéditeur. Réversible.
    func hidePromi(id: UUID) {
        hiddenPromiIds.insert(id.uuidString)
        persistHiddenPromiIds()
        objectWillChange.send()
    }

    /// Ré-affiche un Promi précédemment masqué.
    func showHiddenPromi(id: UUID) {
        hiddenPromiIds.remove(id.uuidString)
        persistHiddenPromiIds()
        objectWillChange.send()
    }

    // MARK: - Query helpers

    func contact(id: String) -> PromiContact? {
        contacts.first { $0.id == id }
    }

    func contacts(matching query: String) -> [PromiContact] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return contactsByRecency }
        return contactsByRecency.filter {
            $0.displayName.lowercased().contains(q)
        }
    }

    /// Tous les contacts NON BLOQUÉS triés par récence d'usage
    /// descendante (plus récents en haut). Sert d'ordre par défaut
    /// dans le picker — on ne propose jamais d'envoyer un Promi à un
    /// contact bloqué. Pour la liste de gestion (Settings), utiliser
    /// `blockedContacts` ou `contacts` directement.
    var contactsByRecency: [PromiContact] {
        contacts
            .filter { !$0.isBlocked }
            .sorted { $0.lastUsedAt > $1.lastUsedAt }
    }

    // MARK: - Persistence

    private func loadContacts() {
        guard
            let data = userDefaults.data(forKey: contactsKey),
            let decoded = try? JSONDecoder().decode([PromiContact].self, from: data)
        else { return }
        contacts = decoded
    }

    private func persistContacts() {
        guard let encoded = try? JSONEncoder().encode(contacts) else { return }
        userDefaults.set(encoded, forKey: contactsKey)
    }

    private func loadHiddenPromiIds() {
        guard
            let data = userDefaults.data(forKey: hiddenPromiIdsKey),
            let decoded = try? JSONDecoder().decode(Set<String>.self, from: data)
        else { return }
        hiddenPromiIds = decoded
    }

    private func persistHiddenPromiIds() {
        guard let encoded = try? JSONEncoder().encode(hiddenPromiIds) else { return }
        userDefaults.set(encoded, forKey: hiddenPromiIdsKey)
    }
}
