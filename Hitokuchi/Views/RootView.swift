import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var storeManager = StoreManagerService()
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(storeManager: storeManager)
            } else {
                OnboardingFlow {
                    hasCompletedOnboarding = true
                }
            }
        }
        .environment(\.locale, LocalizationManager.shared.locale)
        .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
        .task {
            await storeManager.loadProducts()
            await storeManager.updatePurchasedProducts()
        }
    }
}
