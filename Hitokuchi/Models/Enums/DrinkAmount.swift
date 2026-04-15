import Foundation

/// 飲料の量を「ひとくち」単位で表現するenum。
/// 精密なml入力ではなく、日常的な容器サイズで記録する。
enum DrinkAmount: String, CaseIterable, Codable, Sendable {
    /// 湯呑み一杯（≈120ml）
    case yunomi = "yunomi"
    /// お椀一杯（≈180ml）
    case owan = "owan"
    /// マグカップ一杯（≈250ml）
    case mugCup = "mug_cup"
    /// ペットボトル半分（≈250ml）
    case petBottleHalf = "pet_bottle_half"
    /// ペットボトル一本（≈500ml）
    case petBottleFull = "pet_bottle_full"

    var volumeML: Double {
        switch self {
        case .yunomi:        return 120
        case .owan:          return 180
        case .mugCup:        return 250
        case .petBottleHalf: return 250
        case .petBottleFull: return 500
        }
    }

    @MainActor
    var displayName: String {
        switch self {
        case .yunomi:        return L("drinkAmount.yunomi")
        case .owan:          return L("drinkAmount.owan")
        case .mugCup:        return L("drinkAmount.mugCup")
        case .petBottleHalf: return L("drinkAmount.petBottleHalf")
        case .petBottleFull: return L("drinkAmount.petBottleFull")
        }
    }

    @MainActor
    var accessibilityLabel: String {
        switch self {
        case .yunomi:        return L("a11y.drinkAmount.yunomi")
        case .owan:          return L("a11y.drinkAmount.owan")
        case .mugCup:        return L("a11y.drinkAmount.mugCup")
        case .petBottleHalf: return L("a11y.drinkAmount.petBottleHalf")
        case .petBottleFull: return L("a11y.drinkAmount.petBottleFull")
        }
    }

    var iconName: String {
        switch self {
        case .yunomi:        return "cup.and.saucer"
        case .owan:          return "mug"
        case .mugCup:        return "cup.and.saucer.fill"
        case .petBottleHalf: return "waterbottle"
        case .petBottleFull: return "waterbottle.fill"
        }
    }

    static func defaultAmount(for category: BeverageCategory) -> DrinkAmount {
        switch category {
        case .tea:    return .yunomi
        case .soup:   return .owan
        case .coffee: return .mugCup
        case .water:  return .mugCup
        case .juice:  return .mugCup
        case .other:  return .mugCup
        }
    }
}
