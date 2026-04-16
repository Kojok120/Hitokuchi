import SwiftUI
import SwiftData

/// 設定画面のViewModel
@MainActor @Observable
final class SettingsViewModel {
    var settings: UserSettings?
    var storeManager: StoreManagerService
    var isRestoringPurchases: Bool = false
    var restoreMessage: String?

    private let healthStoreService = HealthStoreService()

    init(storeManager: StoreManagerService) {
        self.storeManager = storeManager
    }

    var hasBundleAll: Bool {
        storeManager.hasBundleAll
    }

    var dailyGoalML: Double {
        get { settings?.dailyGoalML ?? 2000 }
        set {
            settings?.dailyGoalML = newValue
            settings?.updatedAt = Date()
        }
    }

    var quietHourStart: Int {
        get { settings?.quietHourStart ?? 22 }
        set {
            settings?.quietHourStart = newValue
            settings?.updatedAt = Date()
        }
    }

    var quietHourEnd: Int {
        get { settings?.quietHourEnd ?? 7 }
        set {
            settings?.quietHourEnd = newValue
            settings?.updatedAt = Date()
        }
    }

    var showNumericValues: Bool {
        get { settings?.showNumericValues ?? false }
        set {
            settings?.showNumericValues = newValue
            settings?.updatedAt = Date()
        }
    }

    var healthKitEnabled: Bool {
        get { settings?.healthKitEnabled ?? false }
        set {
            settings?.healthKitEnabled = newValue
            settings?.updatedAt = Date()
        }
    }

    var selectedTheme: AppTheme {
        get { settings?.selectedTheme ?? .default }
        set {
            settings?.selectedTheme = newValue
        }
    }

    var messageTone: MessageTone {
        get { settings?.messageTone ?? .default }
        set {
            settings?.messageTone = newValue
        }
    }

    var preferredLanguage: AppLanguage {
        get { AppLanguage(rawValue: settings?.preferredLanguageCode ?? "system") ?? .system }
        set {
            settings?.preferredLanguageCode = newValue.rawValue
            settings?.updatedAt = Date()
            LocalizationManager.shared.setLanguage(newValue)
        }
    }

    var goalInCups: Int {
        Int(dailyGoalML / 250)
    }

    func loadSettings(context: ModelContext) {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? context.fetch(descriptor).first {
            settings = existing
        } else {
            let newSettings = UserSettings()
            context.insert(newSettings)
            try? context.save()
            settings = newSettings
        }
    }

    func incrementGoal() {
        let newValue = min(dailyGoalML + 250, 5000)
        dailyGoalML = newValue
    }

    func decrementGoal() {
        let newValue = max(dailyGoalML - 250, 500)
        dailyGoalML = newValue
    }

    func toggleHealthKit() async {
        if !healthKitEnabled {
            do {
                try await healthStoreService.requestAuthorization()
                healthKitEnabled = true
            } catch {
                healthKitEnabled = false
            }
        } else {
            healthKitEnabled = false
        }
    }

    func restorePurchases() async {
        isRestoringPurchases = true
        do {
            try await storeManager.restorePurchases()
            if storeManager.purchasedProductIDs.isEmpty {
                restoreMessage = L("settings.restore.notFound")
            } else {
                restoreMessage = L("settings.restore.success")
            }
        } catch {
            restoreMessage = L("settings.restore.failed")
        }
        isRestoringPurchases = false
    }
}
