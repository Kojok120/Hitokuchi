import Foundation
import SwiftData

/// 水分補給の進捗情報
struct HydrationProgress: Sendable {
    let totalML: Double
    let goalML: Double
    let logCount: Int

    var ratio: Double { goalML > 0 ? totalML / goalML : 0 }
    var percentage: Double { ratio * 100 }
    var stage: ProgressStage { .from(percentage: percentage) }
    var isGoalAchieved: Bool { ratio >= 1.0 }
    var remainingML: Double { max(0, goalML - totalML) }
}

/// 水分計算サービス
struct HydrationCalculatorService: HydrationCalculating {

    func calculateEffectiveWater(beverage: BeverageMaster, amount: DrinkAmount) -> Double {
        amount.volumeML * beverage.hydrationCoefficient
    }

    func todayProgress(in context: ModelContext) -> HydrationProgress {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<DrinkLog> {
            $0.recordedAt >= today && $0.recordedAt < tomorrow
        }
        let descriptor = FetchDescriptor<DrinkLog>(predicate: predicate)
        let todayLogs = (try? context.fetch(descriptor)) ?? []
        let totalEffectiveWater = todayLogs.reduce(0) { $0 + $1.effectiveWaterML }

        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let settings = (try? context.fetch(settingsDescriptor))?.first
        let dailyGoal = settings?.dailyGoalML ?? 2000.0

        return HydrationProgress(
            totalML: totalEffectiveWater,
            goalML: dailyGoal,
            logCount: todayLogs.count
        )
    }
}
