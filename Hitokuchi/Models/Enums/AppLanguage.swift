import Foundation

/// アプリの表示言語
enum AppLanguage: String, CaseIterable, Codable, Sendable {
    case system = "system"
    case ja = "ja"
    case en = "en"
    case ko = "ko"
    case zhHans = "zh-Hans"
    case es = "es"
    case fr = "fr"
    case de = "de"

    var displayName: String {
        switch self {
        case .system: return "システム設定に従う"
        case .ja:     return "日本語"
        case .en:     return "English"
        case .ko:     return "한국어"
        case .zhHans: return "简体中文"
        case .es:     return "Español"
        case .fr:     return "Français"
        case .de:     return "Deutsch"
        }
    }

    /// AppleLanguagesに設定するコード。systemの場合はnil。
    var languageCode: String? {
        self == .system ? nil : rawValue
    }
}
