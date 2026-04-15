import SwiftUI

/// アプリのカラーテーマ。デフォルトは無料、その他はプレミアムまたは個別IAP。
enum AppTheme: String, CaseIterable, Codable, Sendable {
    case `default` = "default"
    case sakura    = "sakura"
    case ocean     = "ocean"
    case forest    = "forest"
    case sunset    = "sunset"
    case night     = "night"

    var productID: String? {
        switch self {
        case .default: return nil
        case .sakura:  return "hitokuchi.theme.sakura"
        case .ocean:   return "hitokuchi.theme.ocean"
        case .forest:  return "hitokuchi.theme.forest"
        case .sunset:  return "hitokuchi.theme.sunset"
        case .night:   return "hitokuchi.theme.night"
        }
    }

    @MainActor
    var displayName: String {
        let key: String
        switch self {
        case .default: key = "theme.default.name"
        case .sakura:  key = "theme.sakura.name"
        case .ocean:   key = "theme.ocean.name"
        case .forest:  key = "theme.forest.name"
        case .sunset:  key = "theme.sunset.name"
        case .night:   key = "theme.night.name"
        }
        return L(key)
    }

    @MainActor
    var themeDescription: String {
        let key: String
        switch self {
        case .default: key = "theme.default.description"
        case .sakura:  key = "theme.sakura.description"
        case .ocean:   key = "theme.ocean.description"
        case .forest:  key = "theme.forest.description"
        case .sunset:  key = "theme.sunset.description"
        case .night:   key = "theme.night.description"
        }
        return L(key)
    }
}
