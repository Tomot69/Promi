import Foundation

enum ReadPathActivationGate {

    enum Decision: Equatable {
        case enableable
        case notEnableable(reason: String)
    }

    static func preflight(defaults: UserDefaults) -> Decision {
        do {
            // 1) PromiStore migrated must be strictly decodable (required)
            let p = try MigratedFilesReader.readPromiStore()
            switch p {
            case .ok, .recoveredFromBackup:
                break
            case .corrupted(let reason):
                return .notEnableable(reason: "PromiStore corrupted: \(reason)")
            }

            // 2) Drafts migrated is best-effort for now (PromiDraft Equatable is NON DÉFINI)
            //    If corrupted/missing, we still allow enabling because runtime fallback exists (legacy lenient).
            _ = try? MigratedFilesReader.readDrafts()

            return .enableable
        } catch {
            return .notEnableable(reason: "Preflight threw")
        }
    }


    static func recordAttempt(decision: Decision) throws {
        let auditURL = try DataRoot.auditFileURL()
        let outcome: String
        let details: String

        switch decision {
        case .enableable:
            outcome = "success"
            details = "enableable"
        case .notEnableable(let reason):
            outcome = "failure"
            details = reason
        }

        let event = try AuditEvent(useCaseId: "READ_PATH_PREFLIGHT", outcome: outcome, details: details)
        try AuditLogger.append(event: event, to: auditURL)
    }
}
