import Foundation

/// 1日の水分補給の進捗段階。
enum ProgressStage: String, CaseIterable, Codable, Sendable {
    case notStarted = "not_started"  // 0%
    case beginning  = "beginning"    // 1-30%
    case onTrack    = "on_track"     // 31-60%
    case almostDone = "almost_done"  // 61-90%
    case achieved   = "achieved"     // 91-100%
    case exceeded   = "exceeded"     // 101%+

    static func from(percentage: Double) -> ProgressStage {
        switch percentage {
        case ...0:       return .notStarted
        case 0..<31:     return .beginning
        case 31..<61:    return .onTrack
        case 61..<91:    return .almostDone
        case 91...100:   return .achieved
        default:         return .exceeded
        }
    }

    @MainActor
    var displayText: String {
        switch self {
        case .notStarted: return L("progress.notStarted")
        case .beginning:  return L("progress.beginning")
        case .onTrack:    return L("progress.onTrack")
        case .almostDone: return L("progress.almostDone")
        case .achieved:   return L("progress.achieved")
        case .exceeded:   return L("progress.exceeded")
        }
    }
}
