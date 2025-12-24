import Foundation
import Combine

final class ReadOnlyPromiStore: ObservableObject {

    @Published private(set) var promis: [PromiItem] = []
    @Published private(set) var bravos: [Bravo] = []
    @Published private(set) var comments: [Comment] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        reload()
    }

    func reload() {
        if let snapshot = try? ReadPathRouter.readSnapshot(defaults: defaults) {
            promis = snapshot.promis
            bravos = snapshot.bravos
            comments = snapshot.comments
        } else {
            promis = LegacyPromiStoreReader.readPromisLenient(from: defaults)
            bravos = LegacyPromiStoreReader.readBravosLenient(from: defaults)
            comments = LegacyPromiStoreReader.readCommentsLenient(from: defaults)
        }
    }
}
