//
//  KarmaState.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation

// MARK: - Karma State
struct KarmaState: Codable {
    var percentage: Int
    var totalPromis: Int
    var completedPromis: Int
    var failedPromis: Int
    var pendingPromis: Int
    
    init(
        percentage: Int = 0,
        totalPromis: Int = 0,
        completedPromis: Int = 0,
        failedPromis: Int = 0,
        pendingPromis: Int = 0
    ) {
        self.percentage = percentage
        self.totalPromis = totalPromis
        self.completedPromis = completedPromis
        self.failedPromis = failedPromis
        self.pendingPromis = pendingPromis
    }
}
