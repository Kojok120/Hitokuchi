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

    var filteredBeverages: [BeverageMaster] {
        guard let category = selectedCategory else {
            return beverages
        }
        return beverages.filter { $0.category == category }
    }

    var groupedBeverages: [(category: BeverageCategory, items: [BeverageMaster])] {
        let grouped = Dictionary(grouping: filteredBeverages) { $0.category }
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
