import Foundation

nonisolated struct SyncEnvelope<T: SyncableEntity>: Sendable {
    let entity: T
    let originDeviceId: String
    var changeTag: String?
    let isTombstone: Bool

    nonisolated init(
        entity: T,
        originDeviceId: String,
        changeTag: String? = nil,
        isTombstone: Bool = false
    ) {
        self.entity = entity
        self.originDeviceId = originDeviceId
        self.changeTag = changeTag
        self.isTombstone = isTombstone
    }
}

nonisolated enum SyncConflictResolution: Sendable {
    case lastWriteWins
    case preserveLocal
    case preserveRemote
}
