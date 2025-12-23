import Foundation

enum LegacyDraftsReader {

    // Legacy behavior: silent failure -> empty
    static func readLenient(from defaults: UserDefaults) -> [PromiDraft] {
        guard let data = defaults.data(forKey: LegacyUserDefaultsKeys.draftsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([PromiDraft].self, from: data)) ?? []
    }

    // Strict behavior: explicit state
    static func readStrict(from defaults: UserDefaults) -> RecoveryResult<[PromiDraft]> {
        guard let data = defaults.data(forKey: LegacyUserDefaultsKeys.draftsKey) else {
            return .corrupted(reason: "Missing key: \(LegacyUserDefaultsKeys.draftsKey)")
        }
        do {
            let decoded = try JSONDecoder().decode([PromiDraft].self, from: data)
            return .ok(decoded)
        } catch {
            return .corrupted(reason: "Decode failed: \(LegacyUserDefaultsKeys.draftsKey)")
        }
    }
}
