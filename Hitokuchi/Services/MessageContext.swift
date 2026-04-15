import Foundation

/// メッセージ生成に必要なコンテキスト情報
struct MessageContext: Sendable {
    let timeOfDay: TimeOfDay
    let beverageCategory: BeverageCategory?
    let beverageName: String?
    let progressStage: ProgressStage
    let dayPattern: DayPattern
    let tone: MessageTone
    let streakDays: Int

    static func afterRecord(
        beverageName: String,
        beverageCategory: BeverageCategory,
        progressStage: ProgressStage,
        tone: MessageTone,
        streakDays: Int = 0,
        hadYesterdayRecord: Bool = true
    ) -> MessageContext {
        MessageContext(
            timeOfDay: .current(),
            beverageCategory: beverageCategory,
            beverageName: beverageName,
            progressStage: progressStage,
            dayPattern: .current(streakDays: streakDays, hadYesterdayRecord: hadYesterdayRecord),
            tone: tone,
            streakDays: streakDays
        )
    }

    static func greeting(
        progressStage: ProgressStage,
        tone: MessageTone,
        streakDays: Int = 0,
        hadYesterdayRecord: Bool = true
    ) -> MessageContext {
        MessageContext(
            timeOfDay: .current(),
            beverageCategory: nil,
            beverageName: nil,
            progressStage: progressStage,
            dayPattern: .current(streakDays: streakDays, hadYesterdayRecord: hadYesterdayRecord),
            tone: tone,
            streakDays: streakDays
        )
    }

    static func reminder(
        remainingRatio: Double,
        tone: MessageTone
    ) -> MessageContext {
        let stage = ProgressStage.from(percentage: (1.0 - remainingRatio) * 100)
        return MessageContext(
            timeOfDay: .current(),
            beverageCategory: nil,
            beverageName: nil,
            progressStage: stage,
            dayPattern: .weekday,
            tone: tone,
            streakDays: 0
        )
    }
}
