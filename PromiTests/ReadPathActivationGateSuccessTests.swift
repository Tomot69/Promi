import XCTest
@testable import Promi

@MainActor
final class ReadPathActivationGateSuccessTests: XCTestCase {

    func test_preflight_enableable_whenPromiStoreMigratedDecodable() throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        // Isoler les fichiers migrés dans un dossier temporaire unique
        let testRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("promi-tests-\(UUID().uuidString)", isDirectory: true)

        PromiStorePaths.testOverrideRootURL = testRoot
        defer { PromiStorePaths.testOverrideRootURL = nil }

        // Écrire un promiStore migré conforme à l’encode officiel
        let snap = PromiStoreSnapshot.v1(promis: [], bravos: [], comments: [])
        let env = VersionedEnvelope(schemaVersion: 1, updatedAt: Date(timeIntervalSince1970: 0), value: snap)
        try JSONStore.write(envelope: env, to: try PromiStorePaths.promiStoreFileURL())

        let decision = ReadPathActivationGate.preflight(defaults: defaults)
        XCTAssertEqual(decision, .enableable)
    }
}

