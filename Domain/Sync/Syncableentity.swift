import Foundation

// MARK: - SyncableEntity
//
// Protocol that any domain entity must adopt to be syncable across
// devices. Marked `nonisolated` to satisfy Swift 6 concurrency rules:
// the project uses `-default-isolation=MainActor`, but `Identifiable.id`
// is nonisolated, so the protocol must be too. The properties are pure
// value reads — no actor isolation needed.

nonisolated protocol SyncableEntity: Identifiable, Sendable where ID == UUID {
    var id: UUID { get }
    var version: Int { get }
    var lastModified: Date { get }
}
