import Foundation
import UserNotifications

enum NotificationService {
    // Anforderung der Berechtigung zur Anzeige von Benachrichtigungen
    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()

        // Überprüfen der aktuellen Benachrichtigungsberechtigungen
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Berechtigung anfordern, wenn noch nicht entschieden wurde
                center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if let error = error {
                        print("⚠️ Notification permission error: \(error)")
                    } else {
                        print("🔔 Notification permission granted: \(granted)")
                    }
                    completion?(granted)
                }

            case .denied:
                // Wenn der Benutzer Benachrichtigungen abgelehnt hat
                print("🔕 Notification permission denied.")
                completion?(false)

            case .authorized, .provisional, .ephemeral:
                // Wenn Benachrichtigungen bereits zugelassen sind
                print("✅ Notification permission already granted.")
                completion?(true)

            @unknown default:
                print("❓ Unknown notification status")
                completion?(false)
            }
        }
    }

    // Benachrichtigung für eine Aufgabe planen
    static func scheduleNotification(for task: Task) {
        guard let dueDate = task.dueDate, dueDate > Date() else { return }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("🔕 Notifications are not authorized. Skipping notification for task: \(task.title)")
                return
            }

            // Benachrichtigungsinhalt erstellen
            let content = UNMutableNotificationContent()
            content.title = "Task Reminder"
            content.body = task.title
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(
                identifier: task.id.uuidString,
                content: content,
                trigger: trigger
            )

            // Benachrichtigung hinzufügen
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule notification: \(error)")
                } else {
                    print("📅 Scheduled notification for task: \(task.title)")
                }
            }
        }
    }

    // Entfernen einer Benachrichtigung für eine bestimmte Aufgabe
    static func removeNotification(for taskID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID.uuidString])
        print("🗑️ Removed notification for task ID: \(taskID)")
    }

    // Alle geplanten Benachrichtigungen entfernen
    static func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🧹 Removed all pending notifications.")
    }

    // Wiederholte Benachrichtigungen (optional)
    static func scheduleRepeatingNotification(for task: Task, repeatInterval _: Calendar.Component = .day) {
        guard let dueDate = task.dueDate, dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true) // Wiederholung aktivieren

        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule repeated notification: \(error)")
            } else {
                print("📅 Scheduled repeated notification for task: \(task.title)")
            }
        }
    }
}
