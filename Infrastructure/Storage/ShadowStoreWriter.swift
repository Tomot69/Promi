import Foundation

enum ShadowStoreWriter {

    // Writes raw bytes only. Store format is NON DEFINI.
    static func writeShadow(data: Data) throws {
        guard ShadowWritePolicy.isEnabled else { return }

        let storeURL = try ShadowPaths.shadowStoreFileURL()
        do {
            try AtomicFileWriter.writeAtomic(data: data, to: storeURL)

            // Audit success (best-effort is forbidden, so audit failure throws)
            let auditURL = try DataRoot.auditFileURL()
            let event = try AuditEvent(useCaseId: "SHADOW_WRITE", outcome: "success", details: "bytes=\(data.count)")
            try AuditLogger.append(event: event, to: auditURL)
        } catch {
            // Attempt to audit failure explicitly; if audit also fails, propagate persistence failure.
            do {
                let auditURL = try DataRoot.auditFileURL()
                let event = try AuditEvent(useCaseId: "SHADOW_WRITE", outcome: "failure", details: "write_failed")
                try AuditLogger.append(event: event, to: auditURL)
            } catch {
                // ignore secondary error; primary contract is failure
            }
            throw PromiError.persistence(.writeFailed)
        }
    }
}
