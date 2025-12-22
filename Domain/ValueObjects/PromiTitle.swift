//
//  PromiTitle.swift
//  PromiTests
//
//  Created by MACBOOKPRO on 22/12/2025.
//

import Foundation

struct PromiTitle: Equatable, Hashable, Codable {
    let value: String

    init(_ raw: String) throws {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            throw PromiError.validation(.empty)
        }
        if trimmed.count > DomainTokens.promiTitleMaxChars {
            throw PromiError.validation(.tooLong(max: DomainTokens.promiTitleMaxChars, got: trimmed.count))
        }
        self.value = trimmed
    }
}

