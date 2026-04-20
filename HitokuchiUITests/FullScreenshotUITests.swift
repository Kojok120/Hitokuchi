import XCTest

/// App Store 用の残り 9 枚（01, 02, 03, 04, 05, 06, 08, 09, 10）を
/// ja / en の両ロケールで自動キャプチャする UITest。
/// 07 premium-pricing は PremiumScreenshotUITests.swift 側で既にキャプチャ済みなので触らない。
///
/// 実行方法（個別）:
///   xcodebuild test \
///     -project Hitokuchi.xcodeproj \
///     -scheme Hitokuchi \
///     -destination 'platform=iOS Simulator,id=B875F4B4-A195-41DF-BF57-ABF9497940D3' \
///     -only-testing:HitokuchiUITests/FullScreenshotUITests/test_capture_01_hero_ja \
///     SCREENSHOT_OUTPUT_DIR=/tmp/hitokuchi-shots
///
/// UITest 内で PNG を SCREENSHOT_OUTPUT_DIR に出力する（環境変数で渡す）。
@MainActor
final class FullScreenshotUITests: XCTestCase {

    override func setUp() async throws {
        continueAfterFailure = false
    }

    // MARK: - Launch helpers

    /// 既定の起動引数セット（オンボーディング済み + 7日ログ + お気に入りシード + 言語固定）
    private func makeApp(language: String, onboarding: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        var args = [
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", language == "ja" ? "ja_JP" : "en_US",
        ]
        if onboarding {
            args += [
                "-hasCompletedOnboarding", "YES",
                "-seed7Days",
                "-seedFavorites",
            ]
        } else {
            args += ["-hasCompletedOnboarding", "NO"]
        }
        app.launchArguments = args
        return app
    }

    private func dismissNotificationAlertIfNeeded(_ app: XCUIApplication) {
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 3) {
            alert.buttons.element(boundBy: 0).tap()
        }
    }

    private func saveScreenshot(_ app: XCUIApplication, filename: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = filename
        attachment.lifetime = .keepAlways
        add(attachment)

        let outputDir = ProcessInfo.processInfo.environment["SCREENSHOT_OUTPUT_DIR"]
            ?? NSTemporaryDirectory()
        let url = URL(fileURLWithPath: outputDir).appendingPathComponent(filename)
        try? screenshot.pngRepresentation.write(to: url)
        print("ScreenshotOut: \(url.path)")
    }

    private func tapTab(_ app: XCUIApplication, labels: [String]) {
        let tabBar = app.tabBars.firstMatch
        _ = tabBar.waitForExistence(timeout: 5)
        for label in labels {
            let btn = tabBar.buttons[label]
            if btn.waitForExistence(timeout: 2) {
                btn.tap()
                return
            }
        }
        print("DEBUG: tab not found for \(labels). Hierarchy:\n\(app.debugDescription)")
    }

    // MARK: - 01 Hero

    func test_capture_01_hero_ja() { run01Hero(lang: "ja") }
    func test_capture_01_hero_en() { run01Hero(lang: "en") }

    private func run01Hero(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["ホーム", "Home"])
        sleep(2)
        saveScreenshot(app, filename: "01-hero-\(lang).png")
    }

    // MARK: - 02 Beverage Select

    func test_capture_02_beverageSelect_ja() { run02Beverage(lang: "ja") }
    func test_capture_02_beverageSelect_en() { run02Beverage(lang: "en") }

    private func run02Beverage(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["ホーム", "Home"])

        let buttonLabel = lang == "ja" ? "ほかの飲みもの" : "Other Drinks"
        let button = app.buttons[buttonLabel]
        if button.waitForExistence(timeout: 5) {
            button.tap()
        } else {
            print("DEBUG 02: button '\(buttonLabel)' not found. Hierarchy:\n\(app.debugDescription)")
        }
        sleep(2)
        saveScreenshot(app, filename: "02-beverage-select-\(lang).png")
    }

    // MARK: - 03 After Log

    func test_capture_03_afterLog_ja() { run03AfterLog(lang: "ja") }
    func test_capture_03_afterLog_en() { run03AfterLog(lang: "en") }

    private func run03AfterLog(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["ホーム", "Home"])

        // 煎茶 / Sencha のクイック記録ボタンをタップ（accessibilityLabel = "煎茶を記録" / "Log Sencha"）
        let labelCandidates = lang == "ja" ? ["煎茶を記録"] : ["Log Sencha"]
        var tapped = false
        for label in labelCandidates {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 5) {
                btn.tap()
                tapped = true
                break
            }
        }
        if !tapped {
            print("DEBUG 03: sencha button not found. Hierarchy:\n\(app.debugDescription)")
        }
        // メッセージ切り替わりを待つ（UndoSnackBar が出る前後を狙う）
        sleep(1)
        saveScreenshot(app, filename: "03-after-log-\(lang).png")
    }

    // MARK: - 04 History Today

    func test_capture_04_historyToday_ja() { run04HistoryToday(lang: "ja") }
    func test_capture_04_historyToday_en() { run04HistoryToday(lang: "en") }

    private func run04HistoryToday(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["きろく", "History"])
        sleep(2)
        saveScreenshot(app, filename: "04-history-today-\(lang).png")
    }

    // MARK: - 05 History Week

    func test_capture_05_historyWeek_ja() { run05HistoryWeek(lang: "ja") }
    func test_capture_05_historyWeek_en() { run05HistoryWeek(lang: "en") }

    private func run05HistoryWeek(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["きろく", "History"])

        // 今週 / This Week セグメント
        let weekLabels = ["今週", "This Week", "Week"]
        var switched = false
        for label in weekLabels {
            let segment = app.buttons[label]
            if segment.waitForExistence(timeout: 2) {
                segment.tap()
                switched = true
                break
            }
        }
        if !switched {
            // fallback: segmented control
            let segmented = app.segmentedControls.firstMatch
            if segmented.exists {
                let buttons = segmented.buttons.allElementsBoundByIndex
                if buttons.count >= 2 {
                    buttons[1].tap()
                    switched = true
                }
            }
        }
        if !switched {
            print("DEBUG 05: week segment not found. Hierarchy:\n\(app.debugDescription)")
        }
        sleep(2)
        saveScreenshot(app, filename: "05-history-week-\(lang).png")
    }

    // MARK: - 06 VoiceOver focus (ベース画像のみ、フォーカスリングは合成で描画)

    func test_capture_06_voiceoverBase_ja() { run06VoiceoverBase(lang: "ja") }
    func test_capture_06_voiceoverBase_en() { run06VoiceoverBase(lang: "en") }

    private func run06VoiceoverBase(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["ホーム", "Home"])
        sleep(2)
        saveScreenshot(app, filename: "06-voiceover-base-\(lang).png")
    }

    // MARK: - 08 Theme Picker

    func test_capture_08_themePicker_ja() { run08ThemePicker(lang: "ja") }
    func test_capture_08_themePicker_en() { run08ThemePicker(lang: "en") }

    private func run08ThemePicker(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["せってい", "Settings"])

        let themeLabels = lang == "ja" ? ["テーマ"] : ["Theme"]
        var opened = false
        for label in themeLabels {
            // staticText → 親 cell をタップ
            let staticText = app.staticTexts[label]
            if staticText.waitForExistence(timeout: 3) {
                staticText.tap()
                opened = true
                break
            }
            let button = app.buttons[label]
            if button.waitForExistence(timeout: 1) {
                button.tap()
                opened = true
                break
            }
        }
        if !opened {
            print("DEBUG 08: theme row not found. Hierarchy:\n\(app.debugDescription)")
        }
        sleep(2)
        saveScreenshot(app, filename: "08-theme-picker-\(lang).png")
    }

    // MARK: - 09 Offline Settings

    func test_capture_09_offlineSettings_ja() { run09OfflineSettings(lang: "ja") }
    func test_capture_09_offlineSettings_en() { run09OfflineSettings(lang: "en") }

    private func run09OfflineSettings(lang: String) {
        let app = makeApp(language: lang)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        tapTab(app, labels: ["せってい", "Settings"])
        sleep(2)
        saveScreenshot(app, filename: "09-offline-settings-\(lang).png")
    }

    // MARK: - 10 Welcome (Onboarding)

    func test_capture_10_welcome_ja() { run10Welcome(lang: "ja") }
    func test_capture_10_welcome_en() { run10Welcome(lang: "en") }

    private func run10Welcome(lang: String) {
        let app = makeApp(language: lang, onboarding: false)
        app.launch()
        dismissNotificationAlertIfNeeded(app)
        // WelcomeView は TabBar を持たない → タイトル出現を待つ
        sleep(3)
        saveScreenshot(app, filename: "10-welcome-\(lang).png")
    }
}
