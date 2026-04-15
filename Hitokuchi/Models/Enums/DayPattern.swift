import Foundation

/// 曜日や使用パターン。メッセージ生成エンジンの軸の一つ。
enum DayPattern: String, Codable, Sendable {
    case weekday  = "weekday"
    case weekend  = "weekend"
    case streak   = "streak"
    case comeback = "comeback"

    static func current(at date: Date = .now, streakDays: Int, hadYesterdayRecord: Bool) -> DayPattern {
        if !hadYesterdayRecord {
            return .comeback
        }
        if streakDays >= 3 {
            return .streak
        }
        let weekday = Calendar.current.component(.weekday, from: date)
        return (weekday == 1 || weekday == 7) ? .weekend : .weekday
    }
}
