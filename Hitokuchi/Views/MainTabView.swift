import SwiftUI
import SwiftData

struct MainTabView: View {
    let storeManager: StoreManagerService

    @Environment(\.colorScheme) private var colorScheme
    @Query private var userSettings: [UserSettings]

    /// UserSettingsから現在のテーマをリアクティブに取得
    private var currentTheme: AppTheme {
        userSettings.first?.selectedTheme ?? .default
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(storeManager: storeManager)
            }
            .tabItem {
                Label(L("tab.home.title"), systemImage: "drop.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label(L("tab.history.title"), systemImage: "book.fill")
            }

            NavigationStack {
                SettingsView(storeManager: storeManager)
            }
            .tabItem {
                Label(L("tab.settings.title"), systemImage: "gearshape.fill")
            }
        }
        .tint(Color.hitokuchi.accentPrimary(for: currentTheme, colorScheme: colorScheme))
        .environment(\.appTheme, currentTheme)
    }
}
