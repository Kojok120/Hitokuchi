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
