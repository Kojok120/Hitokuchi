import SwiftData
import Foundation

/// 飲料マスターデータ。文部科学省食品成分表に準拠した水分係数を持つ。
@Model
final class BeverageMaster {

    @Attribute(.unique)
    var id: UUID

    var name: String
    var categoryRaw: String
    var hydrationCoefficient: Double
    var caffeinePer100ml: Double
    var note: String
    var sortOrder: Int
    var isDefault: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \DrinkLog.beverage)
    var drinkLogs: [DrinkLog] = []

    // MARK: - Computed Properties

    var category: BeverageCategory {
        get { BeverageCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var hasCaffeine: Bool {
        caffeinePer100ml > 0
    }

    func effectiveWater(for amount: DrinkAmount) -> Double {
        amount.volumeML * hydrationCoefficient
    }

    // MARK: - Localization

    /// Japanese name → localization key mapping
    private static let nameToKey: [String: String] = [
        "煎茶": "beverage.sencha",
        "ほうじ茶": "beverage.hojicha",
        "麦茶": "beverage.mugicha",
        "玉露": "beverage.gyokuro",
        "紅茶": "beverage.blackTea",
        "コーヒー（ブラック）": "beverage.coffeeBlack",
        "カフェオレ": "beverage.cafeAuLait",
        "水": "beverage.water",
        "炭酸水": "beverage.sparklingWater",
        "味噌汁": "beverage.misoSoup",
        "スープ": "beverage.soup",
        "オレンジジュース": "beverage.orangeJuice",
        "スポーツドリンク": "beverage.sportsDrink",
        "牛乳": "beverage.milk",
        "豆乳": "beverage.soyMilk",
        "エナジードリンク": "beverage.energyDrink",
        "抹茶": "beverage.matcha",
        "烏龍茶": "beverage.oolongTea",
        "ルイボスティー": "beverage.rooibosTea",
        "甘酒": "beverage.amazake",
        "ココア": "beverage.cocoa",
        "野菜ジュース": "beverage.vegetableJuice",
        "アイスティー": "beverage.icedTea",
        "デカフェコーヒー": "beverage.decafCoffee",
        "白湯": "beverage.hotWater",
        "トマトジュース": "beverage.tomatoJuice",
        "カルピス": "beverage.calpis",
        "ポカリスエット": "beverage.pocariSweat",
    ]

    private static let noteToKey: [String: String] = [
        "カフェインフリー": "beverage.note.caffeineFree",
        "高カフェイン": "beverage.note.highCaffeine",
        "塩分注意": "beverage.note.saltWarning",
        "高糖分・カフェイン": "beverage.note.highSugarCaffeine",
        "糖分注意": "beverage.note.sugarWarning",
    ]

    @MainActor
    var localizedName: String {
        guard let key = Self.nameToKey[name] else { return name }
        let localized = L(key)
        return localized == key ? name : localized
    }

    @MainActor
    var localizedNote: String {
        guard !note.isEmpty, let key = Self.noteToKey[note] else { return note }
        let localized = L(key)
        return localized == key ? note : localized
    }

    // MARK: - Init

    init(
        name: String,
        category: BeverageCategory,
        hydrationCoefficient: Double,
        caffeinePer100ml: Double = 0,
        note: String = "",
        sortOrder: Int = 0,
        isDefault: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.categoryRaw = category.rawValue
        self.hydrationCoefficient = hydrationCoefficient
        self.caffeinePer100ml = caffeinePer100ml
        self.note = note
        self.sortOrder = sortOrder
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}
