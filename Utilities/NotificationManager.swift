//
//  NotificationManager.swift
//  Promi
//
//  Gestion des notifications locales. Pas besoin de serveur ni
//  d'Apple Dev — UNUserNotificationCenter fonctionne en local.
//
//  Deux types de rappels :
//  - Rappel veille : "Ton Promi expire demain" (24h avant)
//  - Rappel jour J : "C'est aujourd'hui !" (le matin à 9h)
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error { print("[Promi] Notification permission error: \(error)") }
        }
    }

    // MARK: - Schedule for a Promi

    /// Programme les rappels pour un Promi. Appelé à la création et
    /// après chaque modification de dueDate. Les anciens rappels pour
    /// ce Promi sont supprimés avant d'en créer de nouveaux.
    func scheduleReminders(for promi: PromiItem, language: String) {
        let center = UNUserNotificationCenter.current()
        let idPrefix = promi.id.uuidString
        // Supprimer les anciens rappels pour ce Promi.
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(idPrefix)-eve",
            "\(idPrefix)-day"
        ])

        let isFrench = !language.lowercased().starts(with: "en")
        let title = promi.title

        // Rappel veille (24h avant)
        let eveDate = Calendar.current.date(byAdding: .hour, value: -24, to: promi.dueDate)
        if let eveDate, eveDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Promi"
            content.body = isFrench
                ? "« \(title) » expire demain"
                : "« \(title) » expires tomorrow"
            content.sound = .default
            content.threadIdentifier = "promi-reminders"

            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: eveDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(idPrefix)-eve",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        // Rappel jour J (9h le matin)
        var dayComps = Calendar.current.dateComponents(
            [.year, .month, .day], from: promi.dueDate
        )
        dayComps.hour = 9
        dayComps.minute = 0
        let dayDate = Calendar.current.date(from: dayComps)
        if let dayDate, dayDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Promi"
            content.body = isFrench
                ? "« \(title) » c'est aujourd'hui !"
                : "« \(title) » is today!"
            content.sound = .default
            content.threadIdentifier = "promi-reminders"

            let trigger = UNCalendarNotificationTrigger(dateMatching: dayComps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(idPrefix)-day",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    /// Supprime tous les rappels pour un Promi (quand il est supprimé
    /// ou marqué comme tenu).
    func cancelReminders(for promiId: UUID) {
        let idPrefix = promiId.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["\(idPrefix)-eve", "\(idPrefix)-day"]
        )
    }

    /// Reprogramme tous les rappels pour tous les Promi ouverts.
    /// Appelé au lancement de l'app pour rattraper les changements
    /// faits hors-ligne ou après une mise à jour.
    func rescheduleAll(promis: [PromiItem], language: String) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for promi in promis where promi.status == .open {
            scheduleReminders(for: promi, language: language)
        }
    }

    func scheduleMidnightCelebration(promiTitle: String, language: String) {
        let isFrench = !language.lowercased().starts(with: "en")
        let content = UNMutableNotificationContent()
        content.title = isFrench ? "Promi de minuit" : "Midnight Promi"
        content.body = isFrench
            ? "\"\(promiTitle)\" — promesse nocturne, karma qui twist."
            : "\"\(promiTitle)\" — a midnight promise, karma twist."
        content.sound = .default
        content.threadIdentifier = "promi-midnight"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "midnight-\(UUID().uuidString.prefix(8))",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
