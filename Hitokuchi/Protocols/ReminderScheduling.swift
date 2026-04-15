import Foundation

/// リマインダースケジューリングプロトコル
@MainActor
protocol ReminderScheduling {
    func reschedule(lastDrinkAt: Date, dailyGoal: Double, currentIntake: Double, quietHourStart: Int, quietHourEnd: Int, tone: MessageTone) async
    func cancelAll() async
    func requestAuthorization() async -> Bool
}
