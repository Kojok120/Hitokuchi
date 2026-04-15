import Foundation

/// HealthKit連携プロトコル
@MainActor
protocol HealthStoreProviding {
    func requestAuthorization() async throws
    func saveWaterIntake(milliliters: Double, date: Date) async throws
    var isAvailable: Bool { get }
}
