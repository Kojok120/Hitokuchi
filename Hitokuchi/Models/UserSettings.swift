import SwiftData
import Foundation

/// ユーザー設定。インスタンスは1つだけ存在する（シングルトン的な運用）。
@Model
final class UserSettings {

    @Attribute(.unique)
    var id: UUID

    var dailyGoalML: Double
    var quietHourStart: Int
    var quietHourEnd: Int
    var showNumericValues: Bool
    var messageToneRaw: String
    var selectedThemeRaw: String
    var healthKitEnabled: Bool
    var favoriteBeverageIDsJSON: String
    var preferredLanguageCode: String = "system"
    var createdAt: Date
    var updatedAt: Date

    @Transient
    private var _cachedFavoriteIDs: [UUID]? = nil

    // MARK: - Computed Properties

    var messageTone: MessageTone {
        get { MessageTone(rawValue: messageToneRaw) ?? .default }
        set { messageToneRaw = newValue.rawValue; updatedAt = Date() }
    }

    var selectedTheme: AppTheme {
        get { AppTheme(rawValue: selectedThemeRaw) ?? .default }
        set { selectedThemeRaw = newValue.rawValue; updatedAt = Date() }
    }

    var favoriteBeverageIDs: [UUID] {
        get {
            if let cached = _cachedFavoriteIDs { return cached }
            guard let data = favoriteBeverageIDsJSON.data(using: .utf8),
                  let ids = try? JSONDecoder().decode([UUID].self, from: data)
            else {
                _cachedFavoriteIDs = []
                return []
            }
            _cachedFavoriteIDs = ids
            return ids
        }
        set {
            _cachedFavoriteIDs = newValue
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                favoriteBeverageIDsJSON = json
            }
            updatedAt = Date()
        }
    }

    /// 目標量をコップ何杯分かで表現（マグカップ250ml基準）
    var goalInCups: Int {
        Int(dailyGoalML / 250)
    }

    // MARK: - Init

    init() {
        self.id = UUID()
        self.dailyGoalML = 2000.0
        self.quietHourStart = 22
        self.quietHourEnd = 7
        self.showNumericValues = false
        self.messageToneRaw = MessageTone.default.rawValue
        self.selectedThemeRaw = AppTheme.default.rawValue
        self.healthKitEnabled = false
        self.favoriteBeverageIDsJSON = "[]"
        self.preferredLanguageCode = "system"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
