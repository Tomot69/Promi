import Foundation
import UserNotifications

// MARK: - NuéeLifecycleManager
//
// Manages the lifecycle of ephemeral Nuées:
//   • Schedules local notifications before expiration (7 days, 1 day, at expiry)
//   • Clears stale notifications for Nuées that no longer exist or were renewed
//   • Requests notification permission on first use (non-blocking)
//
// Called from PromiApp.onAppear on every launch. The manager is stateless
// — it reads the current Nuées, diffs against scheduled notifications,
// and reconciles. No persistence needed beyond UNUserNotificationCenter.
//
// Design: Foundation + UserNotifications only (no SwiftUI). Can be called
// from any context (main actor, background, etc).

enum NuéeLifecycleManager {

    // MARK: - Public API

    /// Scans all Nuées and schedules/updates/removes local notifications
    /// for ephemeral ones approaching expiration. Safe to call on every
    /// app launch — idempotent by design (uses deterministic notification
    /// identifiers that are replaced, not duplicated).
    static func reconcileNotifications(for nuées: [Nuée]) {
        let center = UNUserNotificationCenter.current()

        // Request permission (no-op if already granted or denied).
        // Non-blocking — we schedule notifications optimistically and
        // they'll simply not fire if the user denied permission.
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

        // Remove ALL Nuée-related notifications first, then re-schedule
        // only the ones that are still relevant. This avoids orphaned
        // notifications for deleted or renewed Nuées.
        center.getPendingNotificationRequests { existing in
            let nuéeIds = existing
                .filter { $0.identifier.hasPrefix("nuée-") }
                .map(\.identifier)

            if !nuéeIds.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: nuéeIds)
            }

            // Schedule fresh notifications for active ephemeral Nuées.
            let ephemeral = nuées.filter { $0.isEphemeral && !$0.isExpired }

            for nuée in ephemeral {
                scheduleNotifications(for: nuée, center: center)
            }
        }
    }

    // MARK: - Scheduling

    /// Schedules up to 3 notifications per ephemeral Nuée:
    ///   1. 7 days before expiration  — "La Nuée X expire dans une semaine"
    ///   2. 1 day before expiration   — "La Nuée X expire demain"
    ///   3. At expiration             — "La Nuée X est maintenant archivée"
    ///
    /// Each notification has a deterministic identifier based on the Nuée's
    /// id + the offset, so re-scheduling replaces rather than duplicates.
    private static func scheduleNotifications(
        for nuée: Nuée,
        center: UNUserNotificationCenter
    ) {
        guard let expiresAt = nuée.expiresAt else { return }

        let now = Date()
        let id = nuée.id.uuidString
        let name = nuée.name.isEmpty ? "Sans nom" : nuée.name

        // 7 days before
        let sevenDaysBefore = expiresAt.addingTimeInterval(-7 * 86400)
        if sevenDaysBefore > now {
            let content = makeContent(
                title: "Nuée bientôt archivée",
                body: "La Nuée « \(name) » expire dans une semaine."
            )
            schedule(
                id: "nuée-\(id)-7d",
                content: content,
                at: sevenDaysBefore,
                center: center
            )
        }

        // 1 day before
        let oneDayBefore = expiresAt.addingTimeInterval(-86400)
        if oneDayBefore > now {
            let content = makeContent(
                title: "Nuée expire demain",
                body: "La Nuée « \(name) » sera archivée demain."
            )
            schedule(
                id: "nuée-\(id)-1d",
                content: content,
                at: oneDayBefore,
                center: center
            )
        }

        // At expiration
        if expiresAt > now {
            let content = makeContent(
                title: "Nuée archivée",
                body: "La Nuée « \(name) » est maintenant archivée."
            )
            schedule(
                id: "nuée-\(id)-expire",
                content: content,
                at: expiresAt,
                center: center
            )
        }
    }

    // MARK: - Helpers

    private static func makeContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }

    private static func schedule(
        id: String,
        content: UNMutableNotificationContent,
        at date: Date,
        center: UNUserNotificationCenter
    ) {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        center.add(request) { error in
            if let error = error {
                print("[NuéeLifecycle] Failed to schedule \(id): \(error.localizedDescription)")
            }
        }
    }
}
