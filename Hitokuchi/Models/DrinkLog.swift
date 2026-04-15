import SwiftData
import Foundation

/// 飲料記録。ユーザーが「ひとくち」した記録を1件ずつ保存する。
@Model
final class DrinkLog {

    @Attribute(.unique)
    var id: UUID

    var beverage: BeverageMaster?
    var drinkAmountRaw: String
    var volumeML: Double
    var effectiveWaterML: Double
    var recordedAt: Date
    var syncedToHealthKit: Bool

    // MARK: - Computed Properties

    var drinkAmount: DrinkAmount {
        get { DrinkAmount(rawValue: drinkAmountRaw) ?? .mugCup }
        set { drinkAmountRaw = newValue.rawValue }
    }

    var recordDate: Date {
        Calendar.current.startOfDay(for: recordedAt)
    }

    // MARK: - Init

    init(
        beverage: BeverageMaster,
        drinkAmount: DrinkAmount
    ) {
        self.id = UUID()
        self.beverage = beverage
        self.drinkAmountRaw = drinkAmount.rawValue
        self.volumeML = drinkAmount.volumeML
        self.effectiveWaterML = beverage.effectiveWater(for: drinkAmount)
        self.recordedAt = Date()
        self.syncedToHealthKit = false
    }
}
