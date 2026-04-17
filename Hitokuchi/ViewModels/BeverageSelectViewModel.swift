import SwiftUI
import SwiftData

/// 飲料選択画面のViewModel
@MainActor @Observable
final class BeverageSelectViewModel {
    var beverages: [BeverageMaster] = []
    var selectedCategory: BeverageCategory?
    var expandedBeverageID: UUID?
    var selectedAmount: DrinkAmount?
    var isRecording: Bool = false

    // 計算プロパティで都度算出する。
    // 以前は didSet で先行構築してキャッシュしていたが、@Observable の同一更新サイクル中に
    // 二段目の状態変更が走り AttributeGraph precondition failure を引き起こしていた。
    var groupedBeverages: [(category: BeverageCategory, items: [BeverageMaster])] {
        let source: [BeverageMaster]
        if let category = selectedCategory {
            source = beverages.filter { $0.category == category }
        } else {
            source = beverages
        }
        let grouped = Dictionary(grouping: source) { $0.category }
        return BeverageCategory.allCases.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            return (category: cat, items: items.sorted { $0.sortOrder < $1.sortOrder })
        }
    }

    func loadBeverages(context: ModelContext) {
        let descriptor = FetchDescriptor<BeverageMaster>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        beverages = (try? context.fetch(descriptor)) ?? []
    }

    func selectBeverage(_ beverage: BeverageMaster) {
        if expandedBeverageID == beverage.id {
            expandedBeverageID = nil
            selectedAmount = nil
        } else {
            expandedBeverageID = beverage.id
            selectedAmount = DrinkAmount.defaultAmount(for: beverage.category)
        }
    }

    func selectAmount(_ amount: DrinkAmount) {
        selectedAmount = amount
    }
}
