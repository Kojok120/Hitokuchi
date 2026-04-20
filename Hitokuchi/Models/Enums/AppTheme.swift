import SwiftUI

/// アプリのカラーテーマ。デフォルト（水色）は無料、その他は個別IAP または Everything Pack。
enum AppTheme: String, CaseIterable, Codable, Sendable {
    case `default` = "default"
    case houjicha  = "houjicha"
    case sakura    = "sakura"
    case ocean     = "ocean"
    case forest    = "forest"
    case sunset    = "sunset"
    case night     = "night"

    var productID: String? {
        switch self {
        case .default:  return nil
        case .houjicha: return "hitokuchi.theme.houjicha"
        case .sakura:   return "hitokuchi.theme.sakura"
        case .ocean:    return "hitokuchi.theme.ocean"
        case .forest:   return "hitokuchi.theme.forest"
        case .sunset:   return "hitokuchi.theme.sunset"
        case .night:    return "hitokuchi.theme.night"
        }
    }

    @MainActor
    var displayName: String {
        let key: String
        switch self {
        case .default:  key = "theme.default.name"
        case .houjicha: key = "theme.houjicha.name"
        case .sakura:   key = "theme.sakura.name"
        case .ocean:    key = "theme.ocean.name"
        case .forest:   key = "theme.forest.name"
        case .sunset:   key = "theme.sunset.name"
        case .night:    key = "theme.night.name"
        }
        return L(key)
    }

    @MainActor
    var themeDescription: String {
        let key: String
        switch self {
        case .default:  key = "theme.default.description"
        case .houjicha: key = "theme.houjicha.description"
        case .sakura:   key = "theme.sakura.description"
        case .ocean:    key = "theme.ocean.description"
        case .forest:   key = "theme.forest.description"
        case .sunset:   key = "theme.sunset.description"
        case .night:    key = "theme.night.description"
        }
        return L(key)
    }
}
