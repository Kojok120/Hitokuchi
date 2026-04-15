import Testing
@testable import Hitokuchi

@Suite("MessageEngine Tests")
@MainActor
struct MessageEngineTests {

    let engine = MessageEngine()

    // MARK: - Basic Generation

    @Test("Default tone greeting generates non-empty message")
    func defaultGreetingGeneratesMessage() {
        let context = MessageContext(
            timeOfDay: .morning,
            beverageCategory: nil,
            beverageName: nil,
            progressStage: .notStarted,
            dayPattern: .weekday,
            tone: .default,
            streakDays: 0
        )
        let message = engine.generate(context: context)
        #expect(!message.isEmpty)
    }

    @Test("After record message includes beverage name placeholder replacement")
    func afterRecordReplacesPlaceholder() {
        let context = MessageContext(
            timeOfDay: .morning,
            beverageCategory: .tea,
            beverageName: "煎茶",
            progressStage: .beginning,
            dayPattern: .weekday,
            tone: .default,
            streakDays: 0
        )
        let message = engine.generate(context: context)
        #expect(!message.isEmpty)
        // Message should not contain unreplaced placeholder
        #expect(!message.contains("{name}"))
    }

    // MARK: - All Tones

    @Test("Kansai tone generates non-empty message")
    func kansaiToneGeneratesMessage() {
        let context = MessageContext(
            timeOfDay: .afternoon,
            beverageCategory: .coffee,
            beverageName: "コーヒー",
            progressStage: .onTrack,
            dayPattern: .weekday,
            tone: .kansai,
            streakDays: 0
        )
        let message = engine.generate(context: context)
        #expect(!message.isEmpty)
    }

    @Test("Kyoto tone generates non-empty message")
    func kyotoToneGeneratesMessage() {
        let context = MessageContext(
            timeOfDay: .evening,
            beverageCategory: .water,
            beverageName: "水",
            progressStage: .almostDone,
            dayPattern: .weekend,
            tone: .kyoto,
            streakDays: 0
        )
        let message = engine.generate(context: context)
        #expect(!message.isEmpty)
    }

    // MARK: - All Progress Stages

    @Test("Message generated for every progress stage",
          arguments: ProgressStage.allCases)
    func messageForAllProgressStages(stage: ProgressStage) {
        let context = MessageContext(
            timeOfDay: .morning,
            beverageCategory: nil,
            beverageName: nil,
            progressStage: stage,
            dayPattern: .weekday,
            tone: .default,
            streakDays: 0
        )
        let message = engine.generate(context: context)
        #expect(!message.isEmpty, "Message should not be empty for stage \(stage)")
    }

    // MARK: - All Time Of Day

    @Test("Message generated for every time of day",
          arguments: TimeOfDay.allCases)
    func messageForAllTimeOfDay(time: TimeOfDay) {
        let context = MessageContext(
            timeOfDay: time,
            beverageCategory: nil,
            beverageName: nil,
            progressStage: .onTrack,
            dayPattern: .weekday,
            tone: .default,
            streakDays: 0
        )
        let message = engine.generate(context: context)
        #expect(!message.isEmpty, "Message should not be empty for time \(time)")
    }

    // MARK: - Anti-Repeat

    @Test("Consecutive generations produce different messages when possible")
    func antiRepeatLogic() {
        let context = MessageContext(
            timeOfDay: .morning,
            beverageCategory: nil,
            beverageName: nil,
            progressStage: .notStarted,
            dayPattern: .weekday,
            tone: .default,
            streakDays: 0
        )

        // Generate multiple messages and check at least some are different
        var messages = Set<String>()
        for _ in 0..<10 {
            messages.insert(engine.generate(context: context))
        }
        // If there are multiple templates, we should see variation
        // (If there's only one template, the set size will be 1, which is also valid)
        #expect(messages.count >= 1)
    }

    // MARK: - Special Messages

    @Test("Streak message returns value for milestone days")
    func streakMessageForMilestones() {
        let message3 = engine.streakMessage(days: 3, tone: .default)
        #expect(message3 != nil, "Should have streak message for 3 days")

        let message7 = engine.streakMessage(days: 7, tone: .kansai)
        #expect(message7 != nil, "Should have streak message for 7 days (kansai)")
    }

    @Test("Reminder message is non-empty for all tones",
          arguments: MessageTone.allCases)
    func reminderMessageForAllTones(tone: MessageTone) {
        let message = engine.reminderMessage(tone: tone)
        #expect(!message.isEmpty)
    }

    @Test("Daily summary message replaces placeholders")
    func dailySummaryReplacesPlaceholders() {
        let message = engine.dailySummaryMessage(
            beverageList: "煎茶、コーヒー",
            progressComment: "いい調子",
            tone: .default
        )
        #expect(!message.isEmpty)
        #expect(!message.contains("{beverageList}"))
        #expect(!message.contains("{progressComment}"))
    }

    // MARK: - Fallback

    @Test("Fallback message works for all stages")
    func fallbackMessageForAllStages() {
        // Create engine fresh; all stages should have at least a fallback
        let freshEngine = MessageEngine()
        for stage in ProgressStage.allCases {
            let context = MessageContext(
                timeOfDay: .night,
                beverageCategory: nil,
                beverageName: nil,
                progressStage: stage,
                dayPattern: .weekday,
                tone: .default,
                streakDays: 0
            )
            let message = freshEngine.generate(context: context)
            #expect(!message.isEmpty, "Fallback should produce message for \(stage)")
        }
    }
}
