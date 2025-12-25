import Foundation

enum ReadPathBootstrapper {

    // Read-only hydration: reads snapshot and assigns to existing Stores.
    // No writers/migrators are allowed here.
    static func applyIfEnabled(
        defaults: UserDefaults,
        promiStore: PromiStore,
        draftStore: DraftStore
    ) {
        guard FeatureFlags.useReadPathBootstrapperOnLaunch else { return }

        do {
            let snapshot = try ReadPathRouter.readSnapshot(defaults: defaults)
            promiStore.promis = snapshot.promis
            promiStore.bravos = snapshot.bravos
            promiStore.comments = snapshot.comments
            draftStore.drafts = snapshot.drafts
        } catch {
            // If read-path fails unexpectedly, do nothing (legacy Stores keep their own init/load behavior).
            // No silent writes are possible here.
            return
        }
    }
}
