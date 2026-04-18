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
    
    /// Commentaire affiché sous le score de Karma. Suit le même ton que
    /// les exemples de l'onboarding (sobre, clinique, complice au plus bas).
    /// Strictement aligné avec les formulations de la slide Karma de
    /// l'onboarding pour cohérence narrative bout-en-bout.
    func getRoast(language: String) -> String {
        let karma = karmaState.percentage

        if language.starts(with: "en") {
            if karma >= 90 { return "Your word is signature" }
            else if karma >= 70 { return "Reliable, you keep them" }
            else if karma >= 50 { return "It goes, it comes" }
            else { return "Not gonna lie — time to make this right" }
        } else if language.starts(with: "es") {
            if karma >= 90 { return "Tu palabra es firma" }
            else if karma >= 70 { return "Fiable, los cumples" }
            else if karma >= 50 { return "Va y viene" }
            else { return "No nos vamos a mentir — toca recuperar" }
        } else {
            if karma >= 90 { return "Ta parole vaut signature" }
            else if karma >= 70 { return "Fiable, tu tiens" }
            else if karma >= 50 { return "Ça va, ça vient" }
            else { return "On va pas se mentir — y'a du boulot" }
        }
    }
    
    private func persistKarma() {
        if let encoded = try? JSONEncoder().encode(karmaState) {
            userDefaults.set(encoded, forKey: karmaKey)
        }
    }
}
