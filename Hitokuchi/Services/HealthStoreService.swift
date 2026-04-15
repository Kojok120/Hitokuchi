import Foundation
import HealthKit

/// HealthKit連携サービス。dietaryWater書き込みのみ。
@MainActor
final class HealthStoreService: HealthStoreProviding {
    private let healthStore = HKHealthStore()
    private let waterType = HKQuantityType(.dietaryWater)

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { return }
        try await healthStore.requestAuthorization(
            toShare: [waterType],
            read: [] // Read access is not needed
        )
    }

    func saveWaterIntake(milliliters: Double, date: Date) async throws {
        guard isAvailable else { return }
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: milliliters)
        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: date,
            end: date
        )
        try await healthStore.save(sample)
    }
}
