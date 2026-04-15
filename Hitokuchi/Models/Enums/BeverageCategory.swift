import Foundation

/// 飲料のカテゴリ分類。
enum BeverageCategory: String, CaseIterable, Codable, Sendable {
    case tea = "tea"
    case coffee = "coffee"
    case water = "water"
    case soup = "soup"
    case juice = "juice"
    case other = "other"

    @MainActor
    var displayName: String {
        switch self {
        case .tea:    return L("beverageCategory.tea")
        case .coffee: return L("beverageCategory.coffee")
        case .water:  return L("beverageCategory.water")
        case .soup:   return L("beverageCategory.soup")
        case .juice:  return L("beverageCategory.juice")
        case .other:  return L("beverageCategory.other")
        }
    }

    var iconName: String {
        switch self {
        case .tea:    return "leaf.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .water:  return "drop.fill"
        case .soup:   return "flame.fill"
        case .juice:  return "mug.fill"
        case .other:  return "circle.fill"
        }
    }
}
