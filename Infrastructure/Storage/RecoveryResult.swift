import Foundation

enum RecoveryResult<T> {
    case ok(T)
    case recoveredFromBackup(T)
    case corrupted(reason: String)
}

