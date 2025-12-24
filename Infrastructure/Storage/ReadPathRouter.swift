import Foundation

enum ReadPathRouter {

    static func readSnapshot(defaults: UserDefaults) throws -> ReadModelSnapshot {
        // Prefer migrated drafts if readable
        let drafts: [PromiDraft] = {
            let migrated = try? MigratedFilesReader.readDrafts()
            switch migrated {
            case .ok(let d): return d
            case .recoveredFromBackup(let d): return d
            default: return LegacyDraftsReader.readLenient(from: defaults)
            }
        }()

        // Prefer migrated promiStore if readable
        let promiStore: (promis: [PromiItem], bravos: [Bravo], comments: [Comment]) = {
            let migrated = try? MigratedFilesReader.readPromiStore()
            switch migrated {
            case .ok(let snap): return (snap.promis, snap.bravos, snap.comments)
            case .recoveredFromBackup(let snap): return (snap.promis, snap.bravos, snap.comments)
            default:
                return (
                    LegacyPromiStoreReader.readPromisLenient(from: defaults),
                    LegacyPromiStoreReader.readBravosLenient(from: defaults),
                    LegacyPromiStoreReader.readCommentsLenient(from: defaults)
                )
            }
        }()

        return ReadModelSnapshot(
            drafts: drafts,
            promis: promiStore.promis,
            bravos: promiStore.bravos,
            comments: promiStore.comments
        )
    }
}

