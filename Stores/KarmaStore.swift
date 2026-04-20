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
    
    // MARK: - Streak

    /// Nombre de jours consécutifs avec au moins 1 Promi tenu.
    @Published var currentStreak: Int = UserDefaults.standard.integer(forKey: "promi.streak.current")
    @Published var longestStreak: Int = UserDefaults.standard.integer(forKey: "promi.streak.longest")

    /// Dernier jour où un Promi a été tenu (format yyyyMMdd).
    private var lastStreakDay: String {
        get { userDefaults.string(forKey: "promi.streak.lastDay") ?? "" }
        set { userDefaults.set(newValue, forKey: "promi.streak.lastDay") }
    }

    /// Historique karma : tableau de (date, pourcentage). Max 90 entrées.
    @Published var karmaHistory: [(date: Date, value: Int)] = []

    /// Vérifie si le streak est encore valide. Si le dernier jour
    /// de Promi tenu est avant hier, le streak est cassé → reset 0.
    func validateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let todayStr = formatter.string(from: Date())
        let yesterdayStr = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)

        if lastStreakDay != todayStr && lastStreakDay != yesterdayStr {
            currentStreak = 0
            userDefaults.set(0, forKey: "promi.streak.current")
        }
    }

    func loadHistory() {
        if let data = userDefaults.data(forKey: "promi.karmaHistory"),
           let decoded = try? JSONDecoder().decode([KarmaHistoryEntry].self, from: data) {
            karmaHistory = decoded.map { ($0.date, $0.value) }
        }
        // Point initial si l'historique est vide
        if karmaHistory.isEmpty {
            let today = Calendar.current.startOfDay(for: Date())
            karmaHistory = [(today, karmaState.percentage)]
            persistHistory()
        }
    }

    private func persistHistory() {
        let entries = karmaHistory.suffix(90).map { KarmaHistoryEntry(date: $0.date, value: $0.value) }
        if let data = try? JSONEncoder().encode(entries) {
            userDefaults.set(data, forKey: "promi.karmaHistory")
        }
    }

    /// Appelé quand un Promi est marqué tenu. Met à jour le streak
    /// et enregistre un point dans l'historique karma.
    func recordPromiKept() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let todayStr = formatter.string(from: Date())
        let yesterdayStr = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)

        if lastStreakDay == todayStr {
            // Déjà compté aujourd'hui
        } else if lastStreakDay == yesterdayStr {
            currentStreak += 1
        } else {
            currentStreak = 1
        }
        lastStreakDay = todayStr
        longestStreak = max(longestStreak, currentStreak)
        userDefaults.set(currentStreak, forKey: "promi.streak.current")
        userDefaults.set(longestStreak, forKey: "promi.streak.longest")

        // Point d'historique
        let today = Calendar.current.startOfDay(for: Date())
        if let lastEntry = karmaHistory.last,
           Calendar.current.isDate(lastEntry.date, inSameDayAs: today) {
            karmaHistory[karmaHistory.count - 1] = (today, karmaState.percentage)
        } else {
            karmaHistory.append((today, karmaState.percentage))
            if karmaHistory.count > 90 { karmaHistory.removeFirst() }
        }
        persistHistory()
    }

    private func persistKarma() {
        if let encoded = try? JSONEncoder().encode(karmaState) {
            userDefaults.set(encoded, forKey: karmaKey)
        }
    }
}

struct KarmaHistoryEntry: Codable {
    let date: Date
    let value: Int
}
