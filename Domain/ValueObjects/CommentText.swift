//
//  CommentText.swift
//  PromiTests
//
//  Created by MACBOOKPRO on 22/12/2025.
//

import Foundation

struct CommentText: Equatable, Hashable, Codable {
    let value: String

    init(_ raw: String) throws {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            throw PromiError.validation(.empty)
        }
        if trimmed.count > DomainTokens.commentMaxChars {
            throw PromiError.validation(.tooLong(max: DomainTokens.commentMaxChars, got: trimmed.count))
        }
        self.value = trimmed
    }
}

