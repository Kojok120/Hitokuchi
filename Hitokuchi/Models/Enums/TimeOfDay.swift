import Foundation

/// 時間帯の区分。メッセージ生成エンジンの軸の一つ。
enum TimeOfDay: String, CaseIterable, Codable, Sendable {
    case morning   = "morning"    // 5:00 - 9:59
    case midday    = "midday"     // 10:00 - 13:59
    case afternoon = "afternoon"  // 14:00 - 17:59
    case evening   = "evening"    // 18:00 - 21:59
    case night     = "night"      // 22:00 - 4:59

    static func current(at date: Date = .now) -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<10:  return .morning
        case 10..<14: return .midday
        case 14..<18: return .afternoon
        case 18..<22: return .evening
        default:      return .night
        }
    }

    var greeting: String {
        switch self {
        case .morning:   return "おはようございます"
        case .midday:    return "こんにちは"
        case .afternoon: return "こんにちは"
        case .evening:   return "こんばんは"
        case .night:     return "夜遅くまでお疲れさまです"
        }
    }
}
