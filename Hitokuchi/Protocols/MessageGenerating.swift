import Foundation

/// メッセージ生成プロトコル
@MainActor
protocol MessageGenerating {
    func generate(context: MessageContext) -> String
    func streakMessage(days: Int, tone: MessageTone) -> String?
    func reminderMessage(tone: MessageTone) -> String
    func dailySummaryMessage(beverageList: String, progressComment: String, tone: MessageTone) -> String
}
