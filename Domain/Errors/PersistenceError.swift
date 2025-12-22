// /Promi/Promi/Domain/Errors/PersistenceError.swift

import Foundation

public enum PersistenceError: Error, Equatable {
    case readFailed
    case writeFailed
    case encodeFailed
    case decodeFailed
}
