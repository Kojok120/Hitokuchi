import Foundation
import UserNotifications

/// 適応型リマインダースケジューラ
@MainActor
final class ReminderSchedulerService: ReminderScheduling {
    private let center = UNUserNotificationCenter.current()
    private let messageEngine: any MessageGenerating

    init(messageEngine: any MessageGenerating = MessageEngine()) {
        self.messageEngine = messageEngine
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func reschedule(
        lastDrinkAt: Date,
        dailyGoal: Double,
        currentIntake: Double,
        quietHourStart: Int,
        quietHourEnd: Int
    ) async {
        // Cancel existing notifications
        center.removeAllPendingNotificationRequests()

        // Don't schedule if goal achieved
        guard currentIntake < dailyGoal else { return }

        // Calculate next interval
        let remainingRatio = (dailyGoal - currentIntake) / dailyGoal
        let interval = calculateNextInterval(
            lastDrinkAt: lastDrinkAt,
            remainingRatio: remainingRatio
        )
        let nextDate = lastDrinkAt.addingTimeInterval(interval)

        // Check quiet hours
        let finalDate = isInQuietHours(nextDate, start: quietHourStart, end: quietHourEnd)
            ? nextWakeTime(after: nextDate, wakeHour: quietHourEnd)
            : nextDate

        // Negative interval guard (must_fix from Phase 4 QA)
        let triggerInterval = max(1, finalDate.timeIntervalSinceNow)

        let content = UNMutableNotificationContent()
        content.title = "ひとくち"
        content.body = messageEngine.reminderMessage(tone: .default)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: triggerInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "hitokuchi-reminder",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func cancelAll() async {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Private

    /// Calculate next notification interval based on progress
    private func calculateNextInterval(lastDrinkAt: Date, remainingRatio: Double) -> TimeInterval {
        let baseInterval: TimeInterval = 90 * 60 // 5400 seconds = 90 minutes

        let progressMultiplier: Double
        switch remainingRatio {
        case 0.8...1.0: progressMultiplier = 0.7
        case 0.5..<0.8: progressMultiplier = 1.0
        case 0.2..<0.5: progressMultiplier = 1.3
        default:        progressMultiplier = 1.8
        }

        return baseInterval * progressMultiplier
    }

    private func isInQuietHours(_ date: Date, start: Int, end: Int) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        if start > end {
            // Spans midnight (e.g., 22:00 - 7:00)
            return hour >= start || hour < end
        } else {
            return hour >= start && hour < end
        }
    }

    private func nextWakeTime(after date: Date, wakeHour: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = wakeHour
        components.minute = 0
        components.second = 0

        guard let candidate = Calendar.current.date(from: components) else {
            return date.addingTimeInterval(3600)
        }

        // If the wake time has already passed today, use tomorrow
        if candidate <= date {
            return Calendar.current.date(byAdding: .day, value: 1, to: candidate) ?? date.addingTimeInterval(3600)
        }
        return candidate
    }
}
