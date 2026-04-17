import Foundation

/// 自然言語メッセージ生成エンジン。5軸の組み合わせで200パターン以上。
@MainActor
final class MessageEngine: MessageGenerating {

    static let shared = MessageEngine()

    private var lastMessageHash: Int = 0

    private var isJapanese: Bool {
        let lang = LocalizationManager.shared.currentLanguage
        if lang == .ja { return true }
        if lang == .system {
            return Locale.current.language.languageCode?.identifier == "ja"
        }
        return false
    }

    func generate(context: MessageContext) -> String {
        // Non-Japanese languages use localized messages
        if !isJapanese {
            return localizedMessage(context: context)
        }

        let templates = selectTemplates(for: context)
        guard !templates.isEmpty else {
            return fallbackMessage(context: context)
        }

        // 同じメッセージの連続を避ける
        var selected: String
        if templates.count > 1 {
            let filtered = templates.filter { $0.hashValue != lastMessageHash }
            selected = filtered.randomElement() ?? templates.randomElement()!
        } else {
            selected = templates[0]
        }

        lastMessageHash = selected.hashValue

        return replacePlaceholders(selected, context: context)
    }

    private func localizedMessage(context: MessageContext) -> String {
        if let beverageName = context.beverageName {
            // After-record message
            let progressText = localizedProgressText(for: context.progressStage)
            return L("message.afterRecord", beverageName) + " " + progressText
        } else {
            // Greeting message
            return localizedGreeting(for: context.timeOfDay)
        }
    }

    private func localizedGreeting(for timeOfDay: TimeOfDay) -> String {
        switch timeOfDay {
        case .morning:           return L("message.greeting.morning")
        case .midday, .afternoon: return L("message.greeting.afternoon")
        case .evening:           return L("message.greeting.evening")
        case .night:             return L("message.greeting.night")
        }
    }

    private func localizedProgressText(for stage: ProgressStage) -> String {
        switch stage {
        case .notStarted: return L("message.progress.notStarted")
        case .beginning:  return L("message.progress.beginning")
        case .onTrack:    return L("message.progress.onTrack")
        case .almostDone: return L("message.progress.almostDone")
        case .achieved:   return L("message.progress.achieved")
        case .exceeded:   return L("message.progress.exceeded")
        }
    }

    // MARK: - Template Selection

    private func selectTemplates(for context: MessageContext) -> [String] {
        // Determine which template set to use based on tone
        switch context.tone {
        case .default:
            return selectDefaultTemplates(for: context)
        case .kansai:
            return selectKansaiTemplates(for: context)
        case .kyoto:
            return selectKyotoTemplates(for: context)
        }
    }

    private func selectDefaultTemplates(for context: MessageContext) -> [String] {
        if context.beverageName != nil {
            return filterAfterRecordTemplates(
                MessageTemplates.defaultAfterRecord,
                context: context
            )
        } else {
            return filterGreetingTemplates(
                MessageTemplates.defaultGreeting,
                context: context
            )
        }
    }

    private func selectKansaiTemplates(for context: MessageContext) -> [String] {
        if context.beverageName != nil {
            return filterAfterRecordTemplates(
                MessageTemplates.kansaiAfterRecord,
                context: context
            )
        } else {
            return filterGreetingTemplates(
                MessageTemplates.kansaiGreeting,
                context: context
            )
        }
    }

    private func selectKyotoTemplates(for context: MessageContext) -> [String] {
        if context.beverageName != nil {
            return filterAfterRecordTemplates(
                MessageTemplates.kyotoAfterRecord,
                context: context
            )
        } else {
            return filterGreetingTemplates(
                MessageTemplates.kyotoGreeting,
                context: context
            )
        }
    }

    // MARK: - Filter

    private func filterAfterRecordTemplates(
        _ templates: [(TimeOfDay?, BeverageCategory?, ProgressStage, String)],
        context: MessageContext
    ) -> [String] {
        // Try exact match first (time + category + progress)
        let exact = templates.filter { t in
            (t.0 == nil || t.0 == context.timeOfDay) &&
            (t.1 == nil || t.1 == context.beverageCategory) &&
            t.2 == context.progressStage
        }.map(\.3)

        if !exact.isEmpty { return exact }

        // Try matching progress stage only (with nil time/category)
        let fallback = templates.filter { t in
            t.0 == nil && t.1 == nil && t.2 == context.progressStage
        }.map(\.3)

        return fallback
    }

    private func filterGreetingTemplates(
        _ templates: [(TimeOfDay, ProgressStage, String)],
        context: MessageContext
    ) -> [String] {
        // Try exact match (time + progress)
        let exact = templates.filter { t in
            t.0 == context.timeOfDay && t.1 == context.progressStage
        }.map(\.2)

        if !exact.isEmpty { return exact }

        // Try matching time only
        let byTime = templates.filter { t in
            t.0 == context.timeOfDay
        }.map(\.2)

        return byTime
    }

    // MARK: - Placeholder Replacement

    private func replacePlaceholders(_ template: String, context: MessageContext) -> String {
        var result = template
        if let name = context.beverageName {
            result = result.replacingOccurrences(of: "{name}", with: name)
        }
        return result
    }

    // MARK: - Fallback

    private func fallbackMessage(context: MessageContext) -> String {
        let greeting = context.timeOfDay.greeting
        switch context.progressStage {
        case .notStarted:
            return "\(greeting)。まず一杯、いかがですか"
        case .beginning:
            return "\(greeting)。いい一歩ですね"
        case .onTrack:
            return "\(greeting)。いい調子ですよ"
        case .almostDone:
            return "あと少しで今日の目標ですよ"
        case .achieved:
            return "今日の目標、達成しました"
        case .exceeded:
            return "充分な水分が摂れていますね"
        }
    }

    // MARK: - Special Messages

    func streakMessage(days: Int, tone: MessageTone) -> String? {
        let templates: [(Int, String)]
        switch tone {
        case .default: templates = MessageTemplates.streakDefault
        case .kansai:  templates = MessageTemplates.streakKansai
        case .kyoto:   templates = MessageTemplates.streakKyoto
        }

        // Find the best matching streak milestone
        let matching = templates.filter { $0.0 <= days }.last
        return matching?.1
    }

    func reminderMessage(tone: MessageTone) -> String {
        if !isJapanese {
            return L("notification.fallbackBody")
        }
        let templates: [String]
        switch tone {
        case .default: templates = MessageTemplates.reminderDefault
        case .kansai:  templates = MessageTemplates.reminderKansai
        case .kyoto:   templates = MessageTemplates.reminderKyoto
        }
        return templates.randomElement() ?? "そろそろ一杯いかがですか？"
    }

    func dailySummaryMessage(beverageList: String, progressComment: String, tone: MessageTone) -> String {
        if !isJapanese {
            return L("message.dailySummary", beverageList, progressComment)
        }
        let templates: [String]
        switch tone {
        case .default: templates = MessageTemplates.dailySummaryDefault
        case .kansai:  templates = MessageTemplates.dailySummaryKansai
        case .kyoto:   templates = MessageTemplates.dailySummaryKyoto
        }

        var result = templates.randomElement() ?? templates[0]
        result = result.replacingOccurrences(of: "{beverageList}", with: beverageList)
        result = result.replacingOccurrences(of: "{progressComment}", with: progressComment)
        result = result.replacingOccurrences(of: "{beverageComment}", with: "")
        return result
    }
}
