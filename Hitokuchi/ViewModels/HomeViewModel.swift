import SwiftUI
import SwiftData

/// ホーム画面のViewModel
@MainActor @Observable
final class HomeViewModel {
    var currentMessage: String = ""
    var progress: HydrationProgress = HydrationProgress(totalML: 0, goalML: 2000, logCount: 0)
    var favoriteBeverages: [BeverageMaster] = []
    var isRecording: Bool = false
    var lastRecordedBeverageID: UUID?

    // Undo state
    var undoTarget: DrinkLog?
    var undoSecondsRemaining: Int = 0
    var showUndo: Bool { undoTarget != nil && undoSecondsRemaining > 0 }
    private var undoTask: Task<Void, Never>?

    private let messageEngine: any MessageGenerating
    private let hydrationCalculator: any HydrationCalculating
    private let reminderScheduler: any ReminderScheduling
    private let healthStoreService = HealthStoreService()

    init(
        messageEngine: any MessageGenerating = MessageEngine.shared,
        hydrationCalculator: any HydrationCalculating = HydrationCalculatorService(),
        reminderScheduler: any ReminderScheduling = ReminderSchedulerService()
    ) {
        self.messageEngine = messageEngine
        self.hydrationCalculator = hydrationCalculator
        self.reminderScheduler = reminderScheduler
    }

    // MARK: - Load

    func loadData(context: ModelContext) {
        // Load progress
        progress = hydrationCalculator.todayProgress(in: context)

        // Load settings and favorites
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let settings = (try? context.fetch(settingsDescriptor))?.first ?? UserSettings()
        let favoriteIDSet = Set<UUID>(settings.favoriteBeverageIDs)

        // Load favorite beverages
        let beverageDescriptor = FetchDescriptor<BeverageMaster>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let allBeverages = (try? context.fetch(beverageDescriptor)) ?? []
        favoriteBeverages = allBeverages.filter { favoriteIDSet.contains($0.id) }

        // If no favorites set yet, use first 3
        if favoriteBeverages.isEmpty {
            favoriteBeverages = Array(allBeverages.prefix(3))
        }

        // Cap at max favorites
        if favoriteBeverages.count > HitokuchiLayout.maxFavoriteCount {
            favoriteBeverages = Array(favoriteBeverages.prefix(HitokuchiLayout.maxFavoriteCount))
        }

        // Generate greeting message
        let tone = settings.messageTone
        let streakDays = calculateStreak(context: context)
        let messageContext = MessageContext.greeting(
            progressStage: progress.stage,
            tone: tone,
            streakDays: streakDays
        )
        currentMessage = messageEngine.generate(context: messageContext)
    }

    /// Request notification permission (called once on first appearance)
    func requestNotificationPermissionIfNeeded() async {
        _ = await reminderScheduler.requestAuthorization()
    }

    // MARK: - Record Drink

    func recordDrink(
        beverage: BeverageMaster,
        amount: DrinkAmount,
        context: ModelContext
    ) async {
        isRecording = true
        lastRecordedBeverageID = beverage.id

        // 1. Save to SwiftData
        let log = DrinkLog(beverage: beverage, drinkAmount: amount)
        context.insert(log)
        try? context.save()

        // 2. Save to HealthKit if enabled
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let settings = (try? context.fetch(settingsDescriptor))?.first
        if settings?.healthKitEnabled == true {
            do {
                try await healthStoreService.saveWaterIntake(
                    milliliters: log.effectiveWaterML,
                    date: log.recordedAt
                )
                log.syncedToHealthKit = true
                try? context.save()
            } catch {
                // HealthKit failure doesn't affect the record
            }
        }

        // 3. Update progress
        progress = hydrationCalculator.todayProgress(in: context)

        // 4. Generate after-record message
        let tone = settings?.messageTone ?? .default
        let streakDays = calculateStreak(context: context)
        let messageContext = MessageContext.afterRecord(
            beverageName: beverage.localizedName,
            beverageCategory: beverage.category,
            progressStage: progress.stage,
            tone: tone,
            streakDays: streakDays
        )
        currentMessage = messageEngine.generate(context: messageContext)

        // 5. Reschedule reminder
        await reminderScheduler.reschedule(
            lastDrinkAt: log.recordedAt,
            dailyGoal: progress.goalML,
            currentIntake: progress.totalML,
            quietHourStart: settings?.quietHourStart ?? 22,
            quietHourEnd: settings?.quietHourEnd ?? 7,
            tone: tone
        )

        // 6. VoiceOver announcement
        let announcement = L("a11y.home.recorded.announcement", beverage.localizedName, amount.displayName, Int(amount.volumeML))
        UIAccessibility.post(notification: .announcement, argument: announcement)

        // 7. Start undo timer
        startUndoTimer(for: log)

        isRecording = false

        // Clear the recording indicator after a delay
        try? await Task.sleep(for: .milliseconds(1500))
        lastRecordedBeverageID = nil
    }

    // MARK: - Undo

    func startUndoTimer(for log: DrinkLog) {
        undoTask?.cancel()
        undoTarget = log
        undoSecondsRemaining = 5
        undoTask = Task {
            for _ in 0..<5 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                undoSecondsRemaining -= 1
            }
            undoTarget = nil
            undoTask = nil
        }
    }

    func undoLastRecord(context: ModelContext) {
        undoTask?.cancel()
        undoTask = nil
        guard let log = undoTarget else { return }

        let beverageName = log.beverage?.localizedName ?? ""

        // Delete from SwiftData
        context.delete(log)
        try? context.save()

        undoTarget = nil
        undoSecondsRemaining = 0

        // Refresh progress
        progress = hydrationCalculator.todayProgress(in: context)

        // Refresh message
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let settings = (try? context.fetch(settingsDescriptor))?.first
        let tone = settings?.messageTone ?? .default
        let streakDays = calculateStreak(context: context)
        let messageContext = MessageContext.greeting(
            progressStage: progress.stage,
            tone: tone,
            streakDays: streakDays
        )
        currentMessage = messageEngine.generate(context: messageContext)

        // VoiceOver announcement
        let announcement = L("a11y.home.undone.announcement", beverageName)
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }

    func dismissUndo() {
        undoTask?.cancel()
        undoTask = nil
        undoTarget = nil
        undoSecondsRemaining = 0
    }

    // MARK: - Streak Calculation

    private func calculateStreak(context: ModelContext) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let goalML = (try? context.fetch(settingsDescriptor))?.first?.dailyGoalML ?? 2000.0

        let oldestBound = calendar.date(byAdding: .day, value: -365, to: today)!
        let predicate = #Predicate<DrinkLog> { $0.recordedAt >= oldestBound }
        let descriptor = FetchDescriptor<DrinkLog>(predicate: predicate)
        let allLogs = (try? context.fetch(descriptor)) ?? []

        var dailyTotal: [Date: Double] = [:]
        for log in allLogs {
            let day = calendar.startOfDay(for: log.recordedAt)
            dailyTotal[day, default: 0] += log.effectiveWaterML
        }

        var streak = 0
        for dayOffset in 0..<365 {
            let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let total = dailyTotal[dayStart] ?? 0
            if total >= goalML {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
}
