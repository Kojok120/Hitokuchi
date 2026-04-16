import SwiftUI
import SwiftData

/// オンボーディング画面のViewModel
@MainActor @Observable
final class OnboardingViewModel {
    var selectedBeverageIDs: Set<UUID> = []
    var beverages: [BeverageMaster] = []

    var selectedCount: Int { selectedBeverageIDs.count }
    var canProceed: Bool { selectedCount >= 3 }
    var remainingCount: Int { max(0, 3 - selectedCount) }
    var isAtMax: Bool { selectedCount >= HitokuchiLayout.maxFavoriteCount }

    func loadBeverages(context: ModelContext) {
        let descriptor = FetchDescriptor<BeverageMaster>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        beverages = (try? context.fetch(descriptor)) ?? []
    }

    func toggleBeverage(_ id: UUID) {
        if selectedBeverageIDs.contains(id) {
            selectedBeverageIDs.remove(id)
        } else if selectedCount < HitokuchiLayout.maxFavoriteCount {
            selectedBeverageIDs.insert(id)
        }
        // If already at max, don't add (haptic warning handled in View)
    }

    func complete(context: ModelContext) {
        // Save favorite beverages to UserSettings
        let descriptor = FetchDescriptor<UserSettings>()
        let settings: UserSettings
        if let existing = try? context.fetch(descriptor).first {
            settings = existing
        } else {
            settings = UserSettings()
            context.insert(settings)
        }
        settings.favoriteBeverageIDs = Array(selectedBeverageIDs)
        try? context.save()

        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
