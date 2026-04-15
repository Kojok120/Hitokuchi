import Foundation
import SwiftData

/// 飲料マスターのシードデータ。28種の飲料プリセット。
struct BeverageSeedData {

    static let beverages: [(name: String, category: BeverageCategory,
                            coefficient: Double, caffeine: Double,
                            note: String, order: Int)] = [
        // お茶系
        ("煎茶",       .tea,    0.99, 20,  "",              1),
        ("ほうじ茶",    .tea,    0.99, 20,  "",              2),
        ("麦茶",       .tea,    1.00, 0,   "カフェインフリー",  3),
        ("玉露",       .tea,    0.95, 160, "高カフェイン",     4),
        ("紅茶",       .tea,    0.98, 30,  "",              5),

        // コーヒー系
        ("コーヒー（ブラック）", .coffee, 0.97, 60, "",        6),
        ("カフェオレ",          .coffee, 0.97, 40, "",        7),

        // 水系
        ("水",        .water,  1.00, 0,   "",              8),
        ("炭酸水",    .water,  1.00, 0,   "",              9),

        // 汁物系
        ("味噌汁",    .soup,   0.90, 0,   "塩分注意",       10),
        ("スープ",    .soup,   0.90, 0,   "塩分注意",       11),

        // ジュース系
        ("オレンジジュース",   .juice, 0.95, 0,  "",         12),
        ("スポーツドリンク",   .juice, 0.95, 0,  "",         13),

        // その他
        ("牛乳",              .other, 0.90, 0,  "",         14),
        ("豆乳",              .other, 0.90, 0,  "",         15),
        ("エナジードリンク",    .other, 0.85, 40, "高糖分・カフェイン", 16),

        // 追加12種（文部科学省食品成分表準拠）
        ("抹茶",              .tea,    0.95, 64, "",              17),
        ("烏龍茶",            .tea,    0.99, 20, "",              18),
        ("ルイボスティー",      .tea,    1.00, 0,  "カフェインフリー",  19),
        ("甘酒",              .other,  0.80, 0,  "",              20),
        ("ココア",            .other,  0.85, 10, "",              21),
        ("野菜ジュース",       .juice,  0.90, 0,  "",              22),
        ("アイスティー",       .tea,    0.98, 25, "",              23),
        ("デカフェコーヒー",    .coffee, 0.99, 3,  "",              24),
        ("白湯",              .water,  1.00, 0,  "",              25),
        ("トマトジュース",     .juice,  0.90, 0,  "",              26),
        ("カルピス",           .juice,  0.85, 0,  "糖分注意",       27),
        ("ポカリスエット",     .juice,  0.95, 0,  "",              28),
    ]

    /// 初回起動時にマスターデータを挿入する
    static func seedIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<BeverageMaster>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else { return }

        for item in beverages {
            let master = BeverageMaster(
                name: item.name,
                category: item.category,
                hydrationCoefficient: item.coefficient,
                caffeinePer100ml: item.caffeine,
                note: item.note,
                sortOrder: item.order
            )
            context.insert(master)
        }

        try? context.save()
    }
}
