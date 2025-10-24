//
//  KarmaStore.swift
//  Promi
//
//  Created on 24/10/2025.
//

import Foundation
import Combine

// MARK: - Karma Store
class KarmaStore: ObservableObject {
    @Published var karmaState: KarmaState
    
    private let fileName = "karma.json"
    
    init() {
        if let loaded = Self.loadKarma() {
            self.karmaState = loaded
        } else {
            self.karmaState = KarmaState(percentage: 100)
        }
    }
    
    func updateKarma(basedOn promis: [PromiItem]) {
        guard !promis.isEmpty else { return }
        
        let totalPromis = promis.count
        let donePromis = promis.filter { $0.status == .done }.count
        let expiredPromis = promis.filter { $0.status == .open && $0.dueDate < Date() }.count
        
        // Calcul simple : % de promesses tenues
        let successRate = totalPromis > 0 ? (Double(donePromis) / Double(totalPromis)) * 100 : 100
        let penalty = Double(expiredPromis) * 5 // -5% par promesse expirée
        
        let newPercentage = max(0, min(100, Int(successRate - penalty)))
        karmaState.percentage = newPercentage
        
        // Déblocage badges
        checkBadges()
        
        saveKarma()
    }
    
    private func checkBadges() {
        let karma = karmaState.percentage
        
        if karma >= 100 && !karmaState.earnedBadges.contains(.reliable) {
            karmaState.earnedBadges.insert(.reliable)
            Haptics.shared.success()
        }
        if karma >= 200 && !karmaState.earnedBadges.contains(.consistent) {
            karmaState.earnedBadges.insert(.consistent)
            Haptics.shared.success()
        }
        if karma >= 300 && !karmaState.earnedBadges.contains(.trustKeeper) {
            karmaState.earnedBadges.insert(.trustKeeper)
            Haptics.shared.success()
        }
        if karma >= 400 && !karmaState.earnedBadges.contains(.senseiOfPromises) {
            karmaState.earnedBadges.insert(.senseiOfPromises)
            Haptics.shared.success()
        }
        if karma >= 500 && !karmaState.earnedBadges.contains(.shibuiUnlocked) {
            karmaState.earnedBadges.insert(.shibuiUnlocked)
            Haptics.shared.success()
        }
    }
    
    func getRoast(language: String = "fr") -> String {
        let karma = karmaState.percentage
        let roasts: [String]
        
        if language == "fr" {
            if karma >= 90 {
                roasts = [
                    "Tu tiens parole, c'est chic.",
                    "La constance, c'est toi.",
                    "Fiable comme un métronome.",
                    "Tes Promis sont en or."
                ]
            } else if karma >= 70 {
                roasts = [
                    "Presque parfait. Continue.",
                    "Solide, un peu de marge.",
                    "Belle régularité.",
                    "Tu assures bien."
                ]
            } else if karma >= 50 {
                roasts = [
                    "Fresh start. Be kind.",
                    "Recalibrage en douceur.",
                    "Les petites promesses font les grands jours.",
                    "Respire. Recommence."
                ]
            } else {
                roasts = [
                    "Moins de bruit, plus de tenue.",
                    "Un Promi à la fois.",
                    "La constance, c'est chic. On y va ?",
                    "Aujourd'hui compte."
                ]
            }
        } else {
            if karma >= 90 {
                roasts = [
                    "You keep your word. Classy.",
                    "Consistency is your thing.",
                    "Reliable as clockwork.",
                    "Your promises shine."
                ]
            } else if karma >= 70 {
                roasts = [
                    "Almost perfect. Keep going.",
                    "Solid, with room to grow.",
                    "Nice rhythm.",
                    "You're doing well."
                ]
            } else if karma >= 50 {
                roasts = [
                    "Fresh start. Be kind.",
                    "Gentle recalibration.",
                    "Small promises, big days.",
                    "Breathe. Begin again."
                ]
            } else {
                roasts = [
                    "Less noise, more follow-through.",
                    "One promise at a time.",
                    "Consistency is chic. Ready?",
                    "Today matters."
                ]
            }
        }
        
        return roasts.randomElement() ?? "Keep going."
    }
    
    // MARK: - Persistence
    private func saveKarma() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        if let data = try? JSONEncoder().encode(karmaState) {
            try? data.write(to: url)
        }
    }
    
    private static func loadKarma() -> KarmaState? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("karma.json")
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(KarmaState.self, from: data) {
            return decoded
        }
        return nil
    }
}
