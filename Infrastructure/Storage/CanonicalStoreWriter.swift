import Foundation

enum CanonicalStoreWriter {

    // Writes raw bytes only. Store format is NON DEFINI.
    static func writeCanonical(data: Data) throws {
        guard CanonicalStoreWritePolicy.isEnabled else {
            try audit(outcome: "failure", details: "write_disabled")
            throw PromiError.persistence(.writeFailed)
        }

        do {
            let url = try DataRoot.storeFileURL()
            try AtomicFileWriter.writeAtomic(data: data, to: url)

            // Optional: shadow write (it is separately gated)
            do {
                try ShadowStoreWriter.writeShadow(data: data)
            } catch {
                // Shadow failures are not allowed to be silent: record audit and fail hard.
                try audit(outcome: "failure", details: "shadow_write_failed")
                throw PromiError.persistence(.writeFailed)
            }

            try audit(outcome: "success", details: "bytes=\(data.count)")
        } catch {
            // Ensure failure is audited; then propagate typed failure
            try audit(outcome: "failure", details: "write_failed")
            throw PromiError.persistence(.writeFailed)
        }
    }

    private static func audit(outcome: String, details: String) throws {
        let auditURL = try DataRoot.auditFileURL()
        let event = try AuditEvent(useCaseId: "CANONICAL_STORE_WRITE", outcome: outcome, details: details)
        try AuditLogger.append(event: event, to: auditURL)
    }
}
