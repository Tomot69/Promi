import XCTest
@testable import Promi

private nonisolated struct MockSyncEntity: SyncableEntity, Sendable {
    let id: UUID
    let version: Int
    let lastModified: Date
}

final class SyncEnvelopeRoundTripTests: XCTestCase {

    nonisolated func test_envelope_carriesEntityUnchanged() {
        let entity = MockSyncEntity(id: UUID(), version: 3, lastModified: Date())
        let envelope = SyncEnvelope(entity: entity, originDeviceId: "device-A")
        XCTAssertEqual(envelope.entity.id, entity.id)
        XCTAssertEqual(envelope.entity.version, 3)
        XCTAssertEqual(envelope.originDeviceId, "device-A")
        XCTAssertNil(envelope.changeTag)
        XCTAssertFalse(envelope.isTombstone)
    }

    nonisolated func test_tombstoneEnvelope_carriesDeleteIntent() {
        let entity = MockSyncEntity(id: UUID(), version: 1, lastModified: Date())
        let envelope = SyncEnvelope(entity: entity, originDeviceId: "device-B", isTombstone: true)
        XCTAssertTrue(envelope.isTombstone)
    }

    nonisolated func test_localOnlyBackend_isInactive() {
        let backend = LocalOnlyBackend<MockSyncEntity>()
        XCTAssertFalse(backend.isActive)
    }

    nonisolated func test_localOnlyBackend_pushReturnsImmediately() async throws {
        let backend = LocalOnlyBackend<MockSyncEntity>()
        let entity = MockSyncEntity(id: UUID(), version: 1, lastModified: Date())
        let envelope = SyncEnvelope(entity: entity, originDeviceId: "test")
        try await backend.push(envelope)
    }

    nonisolated func test_localOnlyBackend_fetchAllReturnsEmpty() async throws {
        let backend = LocalOnlyBackend<MockSyncEntity>()
        let result = try await backend.fetchAll()
        XCTAssertTrue(result.isEmpty)
    }

    nonisolated func test_localOnlyBackend_subscribeNeverFires() {
        let backend = LocalOnlyBackend<MockSyncEntity>()
        var fired = false
        backend.subscribe { _ in fired = true }
        XCTAssertFalse(fired)
    }
}
