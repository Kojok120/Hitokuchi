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

    private let messageEngine: any MessageGenerating
    private let hydrationCalculator: any HydrationCalculating
    private let reminderScheduler: any ReminderScheduling
    private let healthStoreService = HealthStoreService()

    init(
        messageEngine: any MessageGenerating = MessageEngine(),
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
        let favoriteIDs = settings.favoriteBeverageIDs

        // Load favorite beverages
        let beverageDescriptor = FetchDescriptor<BeverageMaster>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let allBeverages = (try? context.fetch(beverageDescriptor)) ?? []
        favoriteBeverages = allBeverages.filter { favoriteIDs.contains($0.id) }

        // If no favorites set yet, use first 3
        if favoriteBeverages.isEmpty {
            favoriteBeverages = Array(allBeverages.prefix(3))
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
            quietHourEnd: settings?.quietHourEnd ?? 7
        )

        // 6. VoiceOver announcement
        let announcement = L("a11y.home.recorded.announcement", beverage.localizedName, amount.displayName, Int(amount.volumeML))
        UIAccessibility.post(notification: .announcement, argument: announcement)

        isRecording = false

        // Clear the recording indicator after a delay
        try? await Task.sleep(for: .milliseconds(500))
        lastRecordedBeverageID = nil
    }

    // MARK: - Streak Calculation

    private func calculateStreak(context: ModelContext) -> Int {
        var streak = 0
        let today = Calendar.current.startOfDay(for: .now)
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let goalML = (try? context.fetch(settingsDescriptor))?.first?.dailyGoalML ?? 2000.0

        for dayOffset in 0..<365 {
            let dayStart = Calendar.current.date(byAdding: .day, value: -dayOffset, to: today)!
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

            let predicate = #Predicate<DrinkLog> {
                $0.recordedAt >= dayStart && $0.recordedAt < dayEnd
            }
            let descriptor = FetchDescriptor<DrinkLog>(predicate: predicate)
            let logs = (try? context.fetch(descriptor)) ?? []
            let total = logs.reduce(0) { $0 + $1.effectiveWaterML }

            if total >= goalML {
                streak += 1
            } else if dayOffset > 0 {
                // Don't break on today (might not be done yet)
                break
            } else {
                break
            }
        }
        return streak
    }
}
