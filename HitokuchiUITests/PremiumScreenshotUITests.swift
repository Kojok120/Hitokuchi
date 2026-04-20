import XCTest
import StoreKitTest

/// 07 premium-pricing 用のスクリーンショット自動取得。
/// xcodebuild test で走らせると SKTestSession 経由で実価格が UI に反映される。
@MainActor
final class PremiumScreenshotUITests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false
    }

    func test_capturePremiumPricing_en() throws {
        try runCapture(language: "en", filename: "07-premium-pricing-en.png")
    }

    func test_capturePremiumPricing_ja() throws {
        try runCapture(language: "ja", filename: "07-premium-pricing-ja.png")
    }

    private func runCapture(language: String, filename: String) throws {
        let session = try SKTestSession(configurationFileNamed: "Hitokuchi")
        session.disableDialogs = true
        session.clearTransactions()
        // Always use USA storefront so displayPrice "3.99" renders as "$3.99" (USD).
        // Leaving storefront unset lets a prior JPN state persist in storekitd, producing "¥4".
        session.storefront = "USA"

        let app = XCUIApplication()
        app.launchArguments = [
            "-seed7Days",
            "-hasCompletedOnboarding", "YES",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", language == "ja" ? "ja_JP" : "en_US",
        ]
        app.launch()

        // Dismiss notification permission alert if it appears
        let notifAlert = app.alerts.firstMatch
        if notifAlert.waitForExistence(timeout: 3) {
            let dontAllow = notifAlert.buttons.element(boundBy: 0)
            dontAllow.tap()
        }

        // Navigate: Settings tab → Everything Pack
        let tabBar = app.tabBars.firstMatch
        _ = tabBar.waitForExistence(timeout: 5)
        let settingsLabels = ["せってい", "Settings"]
        var settingsTab: XCUIElement?
        for label in settingsLabels {
            let candidate = tabBar.buttons[label]
            if candidate.waitForExistence(timeout: 2) {
                settingsTab = candidate
                break
            }
            let fallback = app.buttons[label]
            if fallback.waitForExistence(timeout: 1) {
                settingsTab = fallback
                break
            }
        }
        if let tab = settingsTab {
            tab.tap()
        } else {
            // Debug: dump hierarchy
            print("DEBUG hierarchy:\n\(app.debugDescription)")
            XCTFail("Settings tab not found")
            return
        }

        let everythingPackLabels = ["ぜんぶ入りパック", "Everything Pack"]
        var everythingPack: XCUIElement?
        for label in everythingPackLabels {
            let candidate = app.buttons[label]
            if candidate.waitForExistence(timeout: 3) {
                everythingPack = candidate
                break
            }
            let staticText = app.staticTexts[label]
            if staticText.waitForExistence(timeout: 1) {
                everythingPack = staticText
                break
            }
        }
        guard let pack = everythingPack else {
            print("DEBUG hierarchy after settings:\n\(app.debugDescription)")
            XCTFail("Everything Pack row not found")
            return
        }
        pack.tap()

        // Wait for price text from StoreKit to appear
        let priceLocator = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '$' OR label CONTAINS '¥'")).firstMatch
        let priceAppeared = priceLocator.waitForExistence(timeout: 15)
        if !priceAppeared {
            print("WARN: Price text never appeared. Hierarchy:\n\(app.debugDescription)")
        }

        // Small settle delay
        sleep(2)

        // Screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = filename
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also persist to disk so we can copy it out
        let data = screenshot.pngRepresentation
        let outputDir = ProcessInfo.processInfo.environment["SCREENSHOT_OUTPUT_DIR"]
            ?? NSTemporaryDirectory()
        let outputURL = URL(fileURLWithPath: outputDir).appendingPathComponent(filename)
        try? data.write(to: outputURL)
        print("ScreenshotOut: \(outputURL.path)")
    }
}
