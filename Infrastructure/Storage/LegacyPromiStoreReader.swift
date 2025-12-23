import Foundation

enum LegacyPromiStoreReader {

    // Legacy behavior: silent failure -> empty
    static func readPromisLenient(from defaults: UserDefaults) -> [PromiItem] {
        guard let data = defaults.data(forKey: LegacyUserDefaultsKeys.promisKey) else { return [] }
        return (try? JSONDecoder().decode([PromiItem].self, from: data)) ?? []
    }

    static func readBravosLenient(from defaults: UserDefaults) -> [Bravo] {
        guard let data = defaults.data(forKey: LegacyUserDefaultsKeys.bravosKey) else { return [] }
        return (try? JSONDecoder().decode([Bravo].self, from: data)) ?? []
    }

    static func readCommentsLenient(from defaults: UserDefaults) -> [Comment] {
        guard let data = defaults.data(forKey: LegacyUserDefaultsKeys.commentsKey) else { return [] }
        return (try? JSONDecoder().decode([Comment].self, from: data)) ?? []
    }

    // Strict behavior: explicit state
    static func readAllStrict(
        from defaults: UserDefaults
    ) -> RecoveryResult<(promis: [PromiItem], bravos: [Bravo], comments: [Comment])> {
        let decoder = JSONDecoder()

        guard let promisData = defaults.data(forKey: LegacyUserDefaultsKeys.promisKey) else {
            return .corrupted(reason: "Missing key: \(LegacyUserDefaultsKeys.promisKey)")
        }
        guard let bravosData = defaults.data(forKey: LegacyUserDefaultsKeys.bravosKey) else {
            return .corrupted(reason: "Missing key: \(LegacyUserDefaultsKeys.bravosKey)")
        }
        guard let commentsData = defaults.data(forKey: LegacyUserDefaultsKeys.commentsKey) else {
            return .corrupted(reason: "Missing key: \(LegacyUserDefaultsKeys.commentsKey)")
        }

        do {
            let promis = try decoder.decode([PromiItem].self, from: promisData)
            let bravos = try decoder.decode([Bravo].self, from: bravosData)
            let comments = try decoder.decode([Comment].self, from: commentsData)
            return .ok((promis: promis, bravos: bravos, comments: comments))
        } catch {
            return .corrupted(reason: "Decode failed: promis/bravos/comments")
        }
    }
}
