// /Promi/Promi/Domain/Errors/PromiError.swift

import Foundation

public enum PromiError: Error, Equatable {
    case validation(ValidationError)
    case persistence(PersistenceError)
    case corruption(reason: String)
    case security(reason: String)
}

