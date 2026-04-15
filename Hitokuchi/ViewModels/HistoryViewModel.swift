import SwiftUI
import SwiftData

/// 履歴画面のViewModel
@MainActor @Observable
final class HistoryViewModel {
    var selectedSegment: HistorySegment = .today
    var todayLogs: [DrinkLog] = []
    var todayMessage: String = ""
    var todayProgress: HydrationProgress = HydrationProgress(totalML: 0, goalML: 2000, logCount: 0)
    var weeklyMessage: String = ""
    var weekDays: [WeekDayData] = []

    private let messageEngine: any MessageGenerating
    private let hydrationCalculator: any HydrationCalculating

    init(
        messageEngine: any MessageGenerating = MessageEngine(),
        hydrationCalculator: any HydrationCalculating = HydrationCalculatorService()
    ) {
        self.messageEngine = messageEngine
        self.hydrationCalculator = hydrationCalculator
    }

    enum HistorySegment: CaseIterable {
        case today
        case thisWeek
    }

    struct WeekDayData: Identifiable {
        let id = UUID()
        let date: Date
        let dayName: String
        let totalML: Double
        let goalML: Double
        let logCount: Int
        let isToday: Bool
        let summaryText: String

        var status: DayStatus {
            if logCount == 0 { return .noRecord }
            let ratio = goalML > 0 ? totalML / goalML : 0
            if ratio >= 1.0 { return .achieved }
            if ratio >= 0.5 { return .partial }
            return .belowHalf
        }
    }

    enum DayStatus {
        case achieved
        case partial
        case belowHalf
        case noRecord
    }

    /// DayStatusからローカライズ済みテキストを返す（@MainActorコンテキスト内で呼ぶ）
    private static func summaryText(for logCount: Int, totalML: Double, goalML: Double) -> String {
        if logCount == 0 { return L("history.dayStatus.noRecord") }
        let ratio = goalML > 0 ? totalML / goalML : 0
        if ratio >= 1.0 { return L("history.dayStatus.achieved") }
        if ratio >= 0.5 { return L("history.dayStatus.partial") }
        return L("history.dayStatus.belowHalf")
    }

    func loadData(context: ModelContext) {
        loadToday(context: context)
        loadWeek(context: context)
    }

    private func loadToday(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<DrinkLog> {
            $0.recordedAt >= today && $0.recordedAt < tomorrow
        }
        let descriptor = FetchDescriptor<DrinkLog>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.recordedAt, order: .reverse)]
        )
        todayLogs = (try? context.fetch(descriptor)) ?? []
        todayProgress = hydrationCalculator.todayProgress(in: context)

        // Generate today's summary message
        if todayLogs.isEmpty {
            todayMessage = L("history.noRecordToday")
        } else {
            let beverageSummary = summarizeBeverages(todayLogs)
            let settingsDescriptor = FetchDescriptor<UserSettings>()
            let tone = (try? context.fetch(settingsDescriptor))?.first?.messageTone ?? .default
            let progressComment = todayProgress.stage.displayText
            todayMessage = messageEngine.dailySummaryMessage(
                beverageList: beverageSummary,
                progressComment: progressComment,
                tone: tone
            )
        }
    }

    private func loadWeek(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let goalML = (try? context.fetch(settingsDescriptor))?.first?.dailyGoalML ?? 2000.0

        let dayNames = ["日", "月", "火", "水", "木", "金", "土"]
        var days: [WeekDayData] = []
        var achievedCount = 0

        for offset in stride(from: 6, through: 0, by: -1) {
            let dayStart = Calendar.current.date(byAdding: .day, value: -offset, to: today)!
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
            let weekday = Calendar.current.component(.weekday, from: dayStart)

            let predicate = #Predicate<DrinkLog> {
                $0.recordedAt >= dayStart && $0.recordedAt < dayEnd
            }
            let descriptor = FetchDescriptor<DrinkLog>(predicate: predicate)
            let logs = (try? context.fetch(descriptor)) ?? []
            let total = logs.reduce(0) { $0 + $1.effectiveWaterML }

            let summary = Self.summaryText(for: logs.count, totalML: total, goalML: goalML)
            let data = WeekDayData(
                date: dayStart,
                dayName: dayNames[weekday - 1],
                totalML: total,
                goalML: goalML,
                logCount: logs.count,
                isToday: offset == 0,
                summaryText: summary
            )
            days.append(data)

            if data.status == .achieved {
                achievedCount += 1
            }
        }
        weekDays = days

        weeklyMessage = L("history.weeklyMessage", achievedCount)
    }

    func deleteLog(_ log: DrinkLog, context: ModelContext) {
        context.delete(log)
        try? context.save()
        loadData(context: context)
    }

    private func summarizeBeverages(_ logs: [DrinkLog]) -> String {
        var counts: [String: Int] = [:]
        for log in logs {
            let name = log.beverage?.localizedName ?? L("common.unknown")
            counts[name, default: 0] += 1
        }
        let separator = L("history.beverageSeparator")
        return counts.map { L("history.beverageCount", $0.key, $0.value) }.joined(separator: separator)
    }
}
