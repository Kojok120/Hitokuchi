import Foundation
import SwiftData

/// 水分計算プロトコル
protocol HydrationCalculating {
    func calculateEffectiveWater(beverage: BeverageMaster, amount: DrinkAmount) -> Double
    func todayProgress(in context: ModelContext) -> HydrationProgress
}
