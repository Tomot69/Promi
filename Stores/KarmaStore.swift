//
//  KarmaStore.swift
//  Promi
//
//  Created on 25/10/2025.
//

import Foundation
import Combine

// MARK: - Karma Store (SIMPLIFIÉ)
class KarmaStore: ObservableObject {
    @Published var karmaState: KarmaState
    
    private let userDefaults = UserDefaults.standard
    private let karmaKey = "karmaState"
    
    init() {
        if let data = userDefaults.data(forKey: karmaKey),
           let decoded = try? JSONDecoder().decode(KarmaState.self, from: data) {
            self.karmaState = decoded
        } else {
            self.karmaState = KarmaState()
        }
    }
    
    func updateKarma(basedOn promis: [PromiItem]) {
        let total = promis.count
        let completed = promis.filter { $0.status == .done && $0.completedAt ?? Date() <= $0.dueDate }.count
        let failed = promis.filter { $0.status == .done && $0.completedAt ?? Date() > $0.dueDate }.count
        let pending = promis.filter { $0.status == .open }.count
        
        let percentage = total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
        
        karmaState = KarmaState(
            percentage: percentage,
            totalPromis: total,
            completedPromis: completed,
            failedPromis: failed,
            pendingPromis: pending
        )
        
        persistKarma()
        objectWillChange.send()
    }
    
    func getRoast(language: String) -> String {
        let karma = karmaState.percentage
        
        if language.starts(with: "en") {
            if karma >= 90 { return "Legend status unlocked" }
            else if karma >= 70 { return "Solid, keep it up" }
            else if karma >= 50 { return "Room for improvement" }
            else { return "Let's be honest..." }
        } else if language.starts(with: "es") {
            if karma >= 90 { return "Eres una leyenda" }
            else if karma >= 70 { return "Sólido, sigue así" }
            else if karma >= 50 { return "Hay margen de mejora" }
            else { return "Seamos honestos..." }
        } else {
            if karma >= 90 { return "Statut légende débloqué" }
            else if karma >= 70 { return "Solide, continue" }
            else if karma >= 50 { return "Peut mieux faire" }
            else { return "Soyons honnêtes..." }
        }
    }
    
    private func persistKarma() {
        if let encoded = try? JSONEncoder().encode(karmaState) {
            userDefaults.set(encoded, forKey: karmaKey)
        }
    }
}
