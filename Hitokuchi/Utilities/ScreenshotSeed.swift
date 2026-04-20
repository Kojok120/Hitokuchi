#if DEBUG
import Foundation
import SwiftData

/// スクリーンショット撮影専用のデバッグ用シードユーティリティ。
/// 本番ビルドには含まれない（DEBUGのみ）。launch arg `-seed7Days` 経由で起動。
enum ScreenshotSeed {
    /// 撮影用の既定お気に入り（煎茶・コーヒー・味噌汁）を UserSettings に書き込む。
    /// 既にお気に入りが 3 件以上設定済みなら何もしない（idempotent）。
    static func seedFavoriteBeverages(in context: ModelContext) {
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let settings: UserSettings
        if let existing = try? context.fetch(settingsDescriptor).first {
            settings = existing
        } else {
            settings = UserSettings()
            context.insert(settings)
        }
        if settings.favoriteBeverageIDs.count >= 3 { return }

        let targetNames = ["煎茶", "コーヒー（ブラック）", "味噌汁"]
        let descriptor = FetchDescriptor<BeverageMaster>()
        guard let beverages = try? context.fetch(descriptor), !beverages.isEmpty else {
            return
        }
        let ids: [UUID] = targetNames.compactMap { name in
            beverages.first { $0.name == name }?.id
        }
        if !ids.isEmpty {
            settings.favoriteBeverageIDs = ids
            try? context.save()
        }
    }

    /// 過去7日分の多様な飲料記録を投入し、History週ビューを populated 状態にする。
    /// すでに7日以内のログがある場合は何もしない（idempotent）。
    static func seed7DaysOfLogs(in context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today)!

        let existing = FetchDescriptor<DrinkLog>(
            predicate: #Predicate { $0.recordedAt >= sevenDaysAgo }
        )
        if let count = try? context.fetchCount(existing), count > 4 {
            return
        }

        let beverageDescriptor = FetchDescriptor<BeverageMaster>()
        guard let beverages = try? context.fetch(beverageDescriptor), !beverages.isEmpty else {
            return
        }

        func beverage(named name: String) -> BeverageMaster? {
            beverages.first { $0.name == name }
        }

        let plan: [(daysAgo: Int, hour: Int, minute: Int, name: String, amount: DrinkAmount)] = [
            (6, 8, 30, "煎茶", .yunomi),
            (6, 12, 15, "味噌汁", .owan),
            (6, 15, 40, "コーヒー（ブラック）", .mugCup),
            (6, 19, 20, "煎茶", .yunomi),

            (5, 9, 0, "コーヒー（ブラック）", .mugCup),
            (5, 13, 30, "水", .petBottleHalf),
            (5, 18, 45, "ほうじ茶", .yunomi),

            (4, 8, 45, "煎茶", .yunomi),
            (4, 12, 0, "味噌汁", .owan),
            (4, 14, 20, "麦茶", .petBottleHalf),
            (4, 17, 15, "コーヒー（ブラック）", .mugCup),
            (4, 20, 30, "水", .petBottleHalf),

            (3, 9, 15, "コーヒー（ブラック）", .mugCup),
            (3, 11, 50, "水", .petBottleHalf),

            (2, 8, 20, "煎茶", .yunomi),
            (2, 12, 30, "味噌汁", .owan),
            (2, 13, 0, "コーヒー（ブラック）", .mugCup),
            (2, 16, 10, "ほうじ茶", .yunomi),
            (2, 19, 45, "水", .petBottleHalf),

            (1, 9, 0, "コーヒー（ブラック）", .mugCup),
            (1, 12, 15, "味噌汁", .owan),
            (1, 14, 30, "煎茶", .yunomi),
            (1, 18, 0, "麦茶", .petBottleHalf),

            (0, 8, 30, "煎茶", .yunomi),
            (0, 11, 30, "コーヒー（ブラック）", .mugCup),
            (0, 13, 0, "味噌汁", .owan),
            (0, 15, 45, "水", .petBottleHalf)
        ]

        for entry in plan {
            guard let bev = beverage(named: entry.name) else { continue }
            guard let day = calendar.date(byAdding: .day, value: -entry.daysAgo, to: today) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = entry.hour
            components.minute = entry.minute
            guard let recordedAt = calendar.date(from: components) else { continue }

            let log = DrinkLog(beverage: bev, drinkAmount: entry.amount)
            log.recordedAt = recordedAt
            context.insert(log)
        }

        try? context.save()
    }
}
#endif
