// /Promi/Promi/Domain/Errors/ValidationError.swift

import Foundation

public enum ValidationError: Error, Equatable {
    case empty
    case tooLong(max: Int, got: Int)
    case outOfRange(min: Int, max: Int, got: Int)
}

