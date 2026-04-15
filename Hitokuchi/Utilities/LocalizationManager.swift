import SwiftUI

/// アプリ内言語切替を管理するシングルトン
@MainActor @Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    var currentLanguage: AppLanguage = .system {
        didSet {
            updateBundle()
        }
    }

    private(set) var bundle: Bundle = .main

    /// 現在の言語に対応するLocale
    var locale: Locale {
        guard let code = currentLanguage.languageCode else {
            return .current
        }
        return Locale(identifier: code)
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "hitokuchi.preferredLanguage") ?? "system"
        currentLanguage = AppLanguage(rawValue: saved) ?? .system
        updateBundle()
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "hitokuchi.preferredLanguage")
    }

    private func updateBundle() {
        guard let code = currentLanguage.languageCode else {
            bundle = .main
            return
        }

        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            bundle = languageBundle
        } else {
            bundle = .main
        }
    }

    func localizedString(for key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    func localizedString(for key: String, _ args: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: key, value: nil, table: nil)
        return String(format: format, arguments: args)
    }
}

/// 短縮ヘルパー — LocalizationManager経由のローカライズ文字列取得
@MainActor
func L(_ key: String) -> String {
    LocalizationManager.shared.localizedString(for: key)
}

/// フォーマット引数付きヘルパー
@MainActor
func L(_ key: String, _ args: CVarArg...) -> String {
    let format = LocalizationManager.shared.bundle.localizedString(forKey: key, value: nil, table: nil)
    return String(format: format, arguments: args)
}
