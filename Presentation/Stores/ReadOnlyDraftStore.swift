import Foundation
import Combine

final class ReadOnlyDraftStore: ObservableObject {

    @Published private(set) var drafts: [PromiDraft] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        reload()
    }

    func reload() {
        if let snapshot = try? ReadPathRouter.readSnapshot(defaults: defaults) {
            drafts = snapshot.drafts
        } else {
            drafts = LegacyDraftsReader.readLenient(from: defaults)
        }
    }
}
