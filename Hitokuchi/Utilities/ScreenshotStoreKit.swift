#if DEBUG
import Foundation
#if canImport(StoreKitTest)
import StoreKitTest
#endif

/// スクリーンショット撮影用の StoreKit テストセッション管理。
/// launch arg `-useStoreKitTest` 経由でバンドル内の `Hitokuchi.storekit` を読み込み、
/// storekitd に注入することで `Product.products(for:)` が実プロダクトを返せるようにする。
enum ScreenshotStoreKit {
    #if canImport(StoreKitTest)
    nonisolated(unsafe) private static var session: SKTestSession?
    #endif

    @MainActor
    static func activateIfRequested() {
        guard CommandLine.arguments.contains("-useStoreKitTest") else { return }
        // SKTestSession.bundleID() requires XCTestConfiguration and calls abort()
        // outside of a test runner. Only initialize when XCTest context is available.
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil else {
            print("ScreenshotStoreKit: -useStoreKitTest requires XCTest context, skipping")
            return
        }
        #if canImport(StoreKitTest)
        do {
            let created = try SKTestSession(configurationFileNamed: "Hitokuchi")
            created.disableDialogs = true
            created.clearTransactions()
            session = created
        } catch {
            print("ScreenshotStoreKit: failed to start SKTestSession: \(error)")
        }
        #endif
    }
}
#endif
