import SwiftUI
import SwiftData

@main
struct HitokuchiApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                BeverageMaster.self,
                DrinkLog.self,
                UserSettings.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Seed beverage master data on first launch
            let context = modelContainer.mainContext
            BeverageSeedData.seedIfNeeded(in: context)

            #if DEBUG
            if CommandLine.arguments.contains("-seed7Days") {
                ScreenshotSeed.seed7DaysOfLogs(in: context)
            }
            if CommandLine.arguments.contains("-seedFavorites") {
                ScreenshotSeed.seedFavoriteBeverages(in: context)
            }
            ScreenshotStoreKit.activateIfRequested()
            #endif
        } catch {
            fatalError("SwiftData container creation failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
