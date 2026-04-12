import Foundation

// MARK: - FeatureFlags
//
// All flags are `nonisolated` so they can be read from any actor
// context (sync backends running on background tasks, tests, etc).
// They are simple Bool values with no mutable state worth protecting
// — flipping one in development is a deliberate manual action, not
// a runtime concurrency concern.

nonisolated enum FeatureFlags {
    // OFF by default: no behavioral changes unless explicitly enabled.
    nonisolated(unsafe) static var useReadPathBootstrapperOnLaunch: Bool = false

    // MARK: - CloudKit sync
    //
    // OFF by default. Turning this ON requires:
    //   1. A paid Apple Developer account
    //   2. iCloud capability enabled in the Promi target
    //   3. The container "iCloud.com.promi.app" (or similar) created
    //      in the Apple Developer portal
    //   4. Entitlements file updated with the container identifier
    //
    // When OFF, NuéeStore uses LocalOnlyBackend — a no-op sync backend
    // that keeps the app behaving exactly as a local-only app. No
    // CloudKit code path is exercised, no entitlement is needed, no
    // network call is made.
    //
    // When ON, NuéeStore switches to CloudKitNuéeBackend transparently.
    // The store's public API does not change.
    nonisolated(unsafe) static var cloudKitSyncEnabled: Bool = false

    // MARK: - Sync diagnostics
    //
    // When ON, the sync layer logs every push/fetch/delete operation
    // for offline debugging. Independent of the master sync flag —
    // useful even with LocalOnlyBackend.
    nonisolated(unsafe) static var syncDiagnosticsEnabled: Bool = false
}
