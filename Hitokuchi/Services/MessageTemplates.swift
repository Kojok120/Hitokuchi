import Foundation

// MARK: - Message Templates
// 5軸（時間帯 x 飲料 x 進捗 x 曜日 x トーン）で200パターン以上

struct MessageTemplates {

    // MARK: - Default Tone (やさしい標準語)

    static let defaultAfterRecord: [(TimeOfDay?, BeverageCategory?, ProgressStage, String)] = [
        // 朝 x 茶 x 各進捗
        (.morning, .tea, .beginning, "おはようございます。朝の{name}、いい一日の始まりですね"),
        (.morning, .tea, .onTrack, "{name}で順調ですね。今日はいいペースです"),
        (.morning, .tea, .almostDone, "朝から{name}でしっかり。あと少しで達成ですよ"),
        (.morning, .tea, .achieved, "朝のうちに目標達成。{name}でしっかり締めくくりましたね"),
        (.morning, .tea, .exceeded, "充分な水分が摂れていますね。{name}、おいしくいただけましたか"),

        // 朝 x コーヒー
        (.morning, .coffee, .beginning, "おはようございます。朝の{name}でスタートですね"),
        (.morning, .coffee, .onTrack, "朝の{name}、目が覚めますね。いい調子です"),
        (.morning, .coffee, .almostDone, "{name}であと少し。もうすぐ達成ですよ"),
        (.morning, .coffee, .achieved, "目標達成です。朝の{name}、いい締めくくりですね"),

        // 朝 x 水
        (.morning, .water, .beginning, "朝一番のお水、体が喜んでいますよ"),
        (.morning, .water, .onTrack, "朝のお水で順調です。いいペースですね"),
        (.morning, .water, .almostDone, "お水であと少し。達成が見えてきましたよ"),
        (.morning, .water, .achieved, "お水で目標達成。シンプルで素敵ですね"),

        // 朝 x 汁物
        (.morning, .soup, .beginning, "朝の{name}、温まりますね。いい朝食です"),
        (.morning, .soup, .onTrack, "{name}で順調です。体が温まりますね"),

        // 昼 x 各飲料
        (.midday, .tea, .beginning, "お昼の{name}ですね。午後も元気にいきましょう"),
        (.midday, .tea, .onTrack, "お昼の{name}、いいペースで飲めていますよ"),
        (.midday, .tea, .almostDone, "{name}であと少しです。もう一息"),
        (.midday, .tea, .achieved, "お昼に目標達成です。{name}、おいしかったですか"),

        (.midday, .coffee, .beginning, "お昼のコーヒータイム。午後も頑張りましょう"),
        (.midday, .coffee, .onTrack, "お昼の{name}ですね。今日はいいペースです"),
        (.midday, .coffee, .almostDone, "{name}であと少し。もうすぐですよ"),
        (.midday, .coffee, .achieved, "目標達成！お昼の{name}で決めましたね"),

        (.midday, .water, .beginning, "お昼にお水、さっぱりしますね"),
        (.midday, .water, .onTrack, "お水で順調です。いい調子ですよ"),
        (.midday, .soup, .beginning, "お昼の{name}、あったかいですね"),
        (.midday, .soup, .onTrack, "{name}で水分もしっかり。いい調子です"),
        (.midday, .soup, .almostDone, "{name}であと少し。達成まであと一歩です"),

        // 午後 x 各飲料
        (.afternoon, .tea, .beginning, "午後の{name}、ほっと一息つきましょう"),
        (.afternoon, .tea, .onTrack, "午後の{name}でリフレッシュ。いいペースですね"),
        (.afternoon, .tea, .almostDone, "{name}であと少し。もうすぐ達成ですよ"),
        (.afternoon, .tea, .achieved, "午後に目標達成！{name}でゆっくりできましたか"),
        (.afternoon, .tea, .exceeded, "充分ですね。午後の{name}、ゆっくり楽しんでください"),

        (.afternoon, .coffee, .beginning, "午後のコーヒーブレイク。いいですね"),
        (.afternoon, .coffee, .onTrack, "午後の{name}、いいペースで飲めていますよ"),
        (.afternoon, .coffee, .almostDone, "{name}であと少し。頑張れそうですね"),
        (.afternoon, .coffee, .achieved, "目標達成！午後の{name}が決め手でしたね"),

        (.afternoon, .water, .beginning, "午後のお水、すっきりしますね"),
        (.afternoon, .water, .onTrack, "お水で順調です。午後もいい調子ですね"),
        (.afternoon, .water, .almostDone, "お水であと少し。あともう一杯"),
        (.afternoon, .water, .achieved, "お水で目標達成。さっぱりと決めましたね"),

        (.afternoon, .juice, .beginning, "午後の{name}、甘くておいしいですよね"),
        (.afternoon, .juice, .onTrack, "{name}で順調です。いいおやつタイムですね"),

        // 夜 x 各飲料
        (.evening, .tea, .beginning, "夜の{name}、一日の疲れが癒されますね"),
        (.evening, .tea, .onTrack, "夜の{name}でリラックス。今日はいいペースでしたね"),
        (.evening, .tea, .almostDone, "{name}であと少し。今日中に達成できそうですね"),
        (.evening, .tea, .achieved, "今日の目標、達成しました。{name}でゆっくり締めくくりましょう"),
        (.evening, .tea, .exceeded, "充分な水分が摂れました。{name}でほっと一息つきましょう"),

        (.evening, .coffee, .beginning, "夜のコーヒー、リラックスタイムですね"),
        (.evening, .coffee, .onTrack, "夜の{name}、今日はいいペースで飲めましたね"),

        (.evening, .water, .beginning, "夜のお水、体に染みわたりますね"),
        (.evening, .water, .onTrack, "お水で順調です。今日もよく飲めましたね"),
        (.evening, .water, .almostDone, "お水であと少し。今日中にいけそうですね"),
        (.evening, .water, .achieved, "お水で目標達成。すっきりした一日ですね"),

        (.evening, .soup, .beginning, "夜の{name}、温まりますね。おいしそうです"),
        (.evening, .soup, .onTrack, "{name}でしっかり水分補給。いい夕食ですね"),
        (.evening, .soup, .almostDone, "{name}であと少し。もうすぐ達成ですよ"),
        (.evening, .soup, .achieved, "{name}で目標達成！温かい一杯が決め手でしたね"),

        // 汎用（時間帯・飲料を問わない）
        (nil, nil, .notStarted, "今日はまだ何も飲んでいませんね。まず一杯、いかがですか"),
        (nil, nil, .beginning, "{name}を記録しました。はじめの一歩ですね"),
        (nil, nil, .onTrack, "{name}、おいしくいただけましたか。いい調子ですよ"),
        (nil, nil, .almostDone, "{name}であと少しです。もう一息、頑張りましょう"),
        (nil, nil, .achieved, "今日の目標、達成しました。{name}でしっかり締めくくりましたね"),
        (nil, nil, .exceeded, "充分な水分が摂れています。{name}もおいしくいただけましたか"),

        // ジュース系追加
        (nil, .juice, .beginning, "{name}を記録しました。水分補給の一歩ですね"),
        (nil, .juice, .onTrack, "{name}で順調に水分補給できていますよ"),
    ]

    static let defaultGreeting: [(TimeOfDay, ProgressStage, String)] = [
        (.morning, .notStarted, "おはようございます。今日もまず一杯から始めましょう"),
        (.morning, .beginning, "おはようございます。今日もいい朝ですね。水分補給、続けていきましょう"),
        (.morning, .onTrack, "おはようございます。今日もいいペースですね"),
        (.midday, .notStarted, "こんにちは。まだ何も飲んでいませんね。一杯いかがですか"),
        (.midday, .beginning, "お昼ですね。午後も水分補給を忘れずに"),
        (.midday, .onTrack, "いい調子ですね。午後もこのペースで"),
        (.afternoon, .notStarted, "午後になりました。そろそろ一杯いかがですか"),
        (.afternoon, .beginning, "午後ですね。もう少し飲めるといいですね"),
        (.afternoon, .onTrack, "午後もいいペースですね。この調子です"),
        (.evening, .notStarted, "こんばんは。今日はまだ何も記録されていませんね"),
        (.evening, .beginning, "今日はもう少し飲めるといいですね"),
        (.evening, .onTrack, "今日はいいペースで飲めましたね"),
        (.evening, .almostDone, "あと少しで今日の目標ですよ"),
        (.evening, .achieved, "今日の目標は達成済みです。お疲れさまでした"),
        (.night, .notStarted, "夜遅くまでお疲れさまです。水分は足りていますか"),
        (.night, .achieved, "今日の目標は達成済み。ゆっくりお休みください"),
    ]

    // MARK: - 関西弁 Tone

    static let kansaiAfterRecord: [(TimeOfDay?, BeverageCategory?, ProgressStage, String)] = [
        (.morning, .tea, .beginning, "おはよう！朝イチの{name}、ええやん。今日もぼちぼちいこか"),
        (.morning, .tea, .onTrack, "{name}で順調やな。ええペースやで"),
        (.morning, .tea, .almostDone, "朝から{name}でしっかりやな。もうちょいで達成やで"),
        (.morning, .tea, .achieved, "朝のうちに目標クリアや！{name}で締めるとは、さすがやで"),

        (.morning, .coffee, .beginning, "おはよう！朝のコーヒーで目ぇ覚めたかな"),
        (.morning, .coffee, .onTrack, "朝の{name}、ええ感じやで。この調子や"),
        (.morning, .water, .beginning, "朝一のお水、体が喜んどるで"),
        (.morning, .water, .onTrack, "お水で順調や。ええペースやな"),
        (.morning, .soup, .beginning, "朝の{name}、あったまるなぁ。ええ朝メシや"),

        (.midday, .tea, .beginning, "昼の{name}やな。午後もがんばろか"),
        (.midday, .tea, .onTrack, "昼の{name}、ええペースで飲めてるで"),
        (.midday, .tea, .almostDone, "{name}でもうちょいや。いけるいける"),
        (.midday, .tea, .achieved, "昼に目標達成！{name}でキメたな、さすがや"),

        (.midday, .coffee, .beginning, "昼のコーヒータイムやな。午後もいこか"),
        (.midday, .coffee, .onTrack, "昼の{name}やな。ええペースで飲めてるで、その調子や"),
        (.midday, .coffee, .almostDone, "{name}でもうちょいやで。がんばれ"),
        (.midday, .coffee, .achieved, "やったやん！昼の{name}で目標クリアや"),

        (.afternoon, .tea, .beginning, "午後の{name}、ほっと一息やな"),
        (.afternoon, .tea, .onTrack, "午後の{name}でリフレッシュ。ええペースやで"),
        (.afternoon, .tea, .almostDone, "{name}であとちょっとや。いけるで"),
        (.afternoon, .tea, .achieved, "午後に達成！{name}でゆっくりできたかな"),

        (.afternoon, .coffee, .beginning, "午後のコーヒーブレイクやな。ええやん"),
        (.afternoon, .coffee, .onTrack, "午後の{name}、ええペースで飲めてるで"),
        (.afternoon, .water, .beginning, "午後のお水、すっきりするやろ"),
        (.afternoon, .water, .onTrack, "お水で順調や。午後もええ調子やな"),

        (.evening, .tea, .beginning, "夜の{name}、一日の疲れが取れるなぁ"),
        (.evening, .tea, .onTrack, "夜の{name}でリラックスやな。今日はええペースやったで"),
        (.evening, .tea, .almostDone, "{name}であとちょっとや。今日中にいけそうやで"),
        (.evening, .tea, .achieved, "今日の目標クリアや！{name}でゆっくり締めよか"),

        (.evening, .water, .beginning, "夜のお水、体に染みるなぁ"),
        (.evening, .water, .achieved, "お水で目標達成！すっきりした一日やったな"),
        (.evening, .soup, .beginning, "夜の{name}、あったまるなぁ。うまそうやん"),
        (.evening, .soup, .achieved, "{name}で目標達成！あったかい一杯が決め手やったな"),

        (nil, nil, .notStarted, "今日はまだ何も飲んでへんな。まず一杯いこか"),
        (nil, nil, .beginning, "{name}を記録したで。はじめの一歩やな"),
        (nil, nil, .onTrack, "{name}、うまかったか？ええ調子やで"),
        (nil, nil, .almostDone, "{name}であとちょっとや。もうひと踏ん張りやで"),
        (nil, nil, .achieved, "やったやん！今日の目標クリアや。{name}で仕上げるとは、さすがやで"),
        (nil, nil, .exceeded, "充分飲めとるで。{name}もうまくいただけたかな"),
    ]

    static let kansaiGreeting: [(TimeOfDay, ProgressStage, String)] = [
        (.morning, .notStarted, "おはよう！今日もまず一杯からいこか"),
        (.morning, .beginning, "おはよう！今日もええ朝やな。水分補給、続けていこか"),
        (.morning, .onTrack, "おはよう！今日もええペースやで"),
        (.midday, .notStarted, "こんにちは。まだ何も飲んでへんな。一杯いこか"),
        (.midday, .beginning, "お昼やな。午後も水分補給忘れんときや"),
        (.midday, .onTrack, "ええ調子やで。午後もこのペースでいこか"),
        (.afternoon, .notStarted, "午後になったで。そろそろ一杯どうや"),
        (.afternoon, .beginning, "午後やな。もうちょい飲めるとええんやけどな"),
        (.afternoon, .onTrack, "午後もええペースやで。この調子や"),
        (.evening, .notStarted, "こんばんは。今日はまだ何も記録されてへんで"),
        (.evening, .beginning, "今日はもうちょい飲めるとええな"),
        (.evening, .onTrack, "今日はええペースで飲めたな"),
        (.evening, .almostDone, "もうちょいで今日の目標やで"),
        (.evening, .achieved, "今日の目標は達成済みや。お疲れさん"),
        (.night, .notStarted, "夜遅くまでお疲れさん。水分は足りとるか"),
        (.night, .achieved, "今日の目標は達成済みや。ゆっくり休みや"),
    ]

    // MARK: - 京都弁 Tone

    static let kyotoAfterRecord: [(TimeOfDay?, BeverageCategory?, ProgressStage, String)] = [
        (.morning, .tea, .beginning, "おはようさん。朝のお{name}、よろしいどすなぁ。ゆるりと始めましょ"),
        (.morning, .tea, .onTrack, "{name}でええ塩梅に飲めてはりますなぁ"),
        (.morning, .tea, .almostDone, "朝からしっかり飲んではりますなぁ。あとちょっとどすえ"),
        (.morning, .tea, .achieved, "朝のうちに達成どすか。お{name}で締めはるとは、なかなか粋どすなぁ"),

        (.morning, .coffee, .beginning, "おはようさん。朝のコーヒー、よろしいどすなぁ"),
        (.morning, .coffee, .onTrack, "朝の{name}、ええ塩梅どす"),
        (.morning, .water, .beginning, "朝一番のお水、お体が喜んではりますわ"),
        (.morning, .soup, .beginning, "朝の{name}、あったかくてよろしいどすなぁ"),

        (.midday, .tea, .beginning, "お昼の{name}どすか。午後もよろしゅうに"),
        (.midday, .tea, .onTrack, "お昼の{name}、ええ塩梅に飲めてはりますなぁ"),
        (.midday, .tea, .almostDone, "{name}であとちょっとどすえ。もうすぐどす"),
        (.midday, .tea, .achieved, "お昼に達成どすか。{name}で決めはりましたなぁ"),

        (.midday, .coffee, .beginning, "お昼のコーヒーどすか。ゆっくりしておくれやす"),
        (.midday, .coffee, .onTrack, "お昼の{name}どすか。ええ塩梅に飲めてはりますなぁ"),

        (.afternoon, .tea, .beginning, "午後のお{name}、ほっこりしますなぁ"),
        (.afternoon, .tea, .onTrack, "午後のお{name}でリフレッシュ。ええ塩梅どす"),
        (.afternoon, .tea, .almostDone, "お{name}であとちょっとどすえ"),
        (.afternoon, .tea, .achieved, "午後に達成どすか。お{name}でゆるりとできましたかなぁ"),

        (.afternoon, .coffee, .beginning, "午後のコーヒーブレイクどすな。よろしいどすなぁ"),
        (.afternoon, .water, .beginning, "午後のお水、すっきりしますなぁ"),

        (.evening, .tea, .beginning, "夜のお{name}、一日のお疲れが癒されますなぁ"),
        (.evening, .tea, .onTrack, "夜のお{name}でリラックス。今日はええ塩梅どしたなぁ"),
        (.evening, .tea, .almostDone, "お{name}であとちょっとどすえ。今日中にいけそうどすなぁ"),
        (.evening, .tea, .achieved, "今日の目標、達成どすか。お{name}でゆるりと締めましょ"),

        (.evening, .water, .achieved, "お水で目標達成どすか。すっきりした一日どしたなぁ"),
        (.evening, .soup, .beginning, "夜の{name}、あったかくてよろしいどすなぁ"),
        (.evening, .soup, .achieved, "{name}で目標達成どすか。あったかい一杯が決め手どしたなぁ"),

        (nil, nil, .notStarted, "今日はまだ何もお飲みになってはりませんなぁ。まず一杯いかがどす"),
        (nil, nil, .beginning, "{name}を記録しましたえ。はじめの一歩どすなぁ"),
        (nil, nil, .onTrack, "{name}、おいしゅうございましたか。ええ塩梅どすえ"),
        (nil, nil, .almostDone, "{name}であとちょっとどすえ。もうひと息"),
        (nil, nil, .achieved, "まあ、もう達成どすか。{name}で締めはるとは、なかなか粋どすなぁ"),
        (nil, nil, .exceeded, "充分お飲みになってはりますなぁ。{name}もよろしゅうございましたか"),
    ]

    static let kyotoGreeting: [(TimeOfDay, ProgressStage, String)] = [
        (.morning, .notStarted, "おはようさん。今日もまず一杯から始めましょ"),
        (.morning, .beginning, "おはようさん。今日もよろしいお天気どすなぁ"),
        (.morning, .onTrack, "おはようさん。今日もええ塩梅どす"),
        (.midday, .notStarted, "こんにちは。まだ何もお飲みになってはりませんなぁ"),
        (.midday, .beginning, "お昼どすなぁ。午後もお体大事にしとくれやす"),
        (.midday, .onTrack, "ええ塩梅どすなぁ。午後もこの調子で"),
        (.afternoon, .notStarted, "午後になりましたえ。そろそろ一杯いかがどす"),
        (.afternoon, .beginning, "午後どすなぁ。もうちょっと飲めはるとよろしいんどすけどなぁ"),
        (.afternoon, .onTrack, "午後もええ塩梅どすなぁ。この調子で"),
        (.evening, .notStarted, "こんばんは。今日はまだ何も記録されてはりませんなぁ"),
        (.evening, .beginning, "今日はもうちょっと飲めはるとよろしいんどすけどなぁ"),
        (.evening, .onTrack, "今日はええ塩梅に飲めはりましたなぁ"),
        (.evening, .almostDone, "あとちょっとで今日の目標どすえ"),
        (.evening, .achieved, "今日の目標は達成どす。お疲れさまどした"),
        (.night, .notStarted, "夜遅くまでお疲れさまどす。水分は足りてはりますか"),
        (.night, .achieved, "今日の目標は達成どす。ゆっくりお休みやす"),
    ]

    // MARK: - 日次・週次振り返り

    static let dailySummaryDefault: [String] = [
        "今日は{beverageList}をいただきました。{progressComment}",
        "今日の水分補給、{progressComment}。{beverageComment}",
    ]

    static let dailySummaryKansai: [String] = [
        "今日は{beverageList}やったな。{progressComment}",
        "今日の水分補給、{progressComment}。{beverageComment}",
    ]

    static let dailySummaryKyoto: [String] = [
        "今日は{beverageList}をいただきましたえ。{progressComment}",
        "今日の水分補給、{progressComment}。{beverageComment}",
    ]

    static let weeklySummaryDefault: [String] = [
        "今週は{achievedDays}日中{totalDays}日、目標を達成できました。{weeklyComment}",
    ]

    static let weeklySummaryKansai: [String] = [
        "今週は{achievedDays}日中{totalDays}日、目標クリアしたで。{weeklyComment}",
    ]

    static let weeklySummaryKyoto: [String] = [
        "今週は{achievedDays}日中{totalDays}日、目標を達成されましたえ。{weeklyComment}",
    ]

    // MARK: - リマインダーメッセージ

    static let reminderDefault: [String] = [
        "そろそろ一杯いかがですか？",
        "水分補給の時間ですよ",
        "ひとくち、飲みませんか？",
        "そろそろ一杯いかがですか？あと少しで今日の目標ですよ",
    ]

    static let reminderKansai: [String] = [
        "そろそろ一杯どうや？",
        "水分補給の時間やで",
        "ひとくち、飲まへん？",
        "そろそろ一杯どうや？もうちょいで今日の目標やで",
    ]

    static let reminderKyoto: [String] = [
        "そろそろ一杯いかがどす？",
        "お水分補給のお時間どすえ",
        "ひとくち、いかがどす？",
        "そろそろ一杯いかがどす？あとちょっとで今日の目標どすえ",
    ]

    // MARK: - 飲めなかった日

    static let lowIntakeDefault: [String] = [
        "今日はあまり飲めませんでしたね。そんな日もあります。明日また一杯から始めましょう",
        "忙しい一日でしたか。お体、大事にしてくださいね",
    ]

    static let lowIntakeKansai: [String] = [
        "今日はあんまり飲めへんかったな。まあそんな日もあるわ。明日またぼちぼちいこか",
        "忙しかったんやな。体、大事にしいや",
    ]

    static let lowIntakeKyoto: [String] = [
        "今日はちょっとお忙しかったんどすかなぁ。お体、大事にしとくれやす",
        "あまりお飲みになれませんどしたな。そんな日もありますえ。明日またゆるりと",
    ]

    // MARK: - 連続達成

    static let streakDefault: [(Int, String)] = [
        (3, "3日連続で目標達成！コツコツ頑張っていますね"),
        (5, "5日連続達成！素晴らしい習慣ですね"),
        (7, "1週間連続達成！水分補給の達人ですね"),
        (14, "2週間連続！もう立派な習慣ですね"),
        (30, "1ヶ月連続達成！本当にすごいです"),
    ]

    static let streakKansai: [(Int, String)] = [
        (3, "3日連続やで！ほんまコツコツ頑張っとるなぁ。えらいえらい"),
        (5, "5日連続達成！すごいやん。この調子やで"),
        (7, "1週間連続やで！水分補給の達人やな"),
        (14, "2週間連続！もう立派な習慣やで"),
        (30, "1ヶ月連続達成！ほんまにすごいで"),
    ]

    static let streakKyoto: [(Int, String)] = [
        (3, "3日もお続けになって、ほんまにえらいことどす。これからもよろしゅうに"),
        (5, "5日連続達成どすか。大したもんどすなぁ"),
        (7, "1週間連続どすか。水分補給のお達人どすなぁ"),
        (14, "2週間連続どすか。もう立派なお習慣どすなぁ"),
        (30, "1ヶ月連続達成どすか。ほんまにお見事どす"),
    ]

    // MARK: - 週末メッセージ

    static let weekendDefault: [String] = [
        "お休みの日ですね。ゆっくりでいいですから、まず一杯飲んでいきましょう",
        "週末ですね。リラックスしながら水分補給を",
    ]

    static let weekendKansai: [String] = [
        "お休みの朝やな。ゆっくりでええから、まず一杯飲んでいき",
        "週末やな。のんびり水分補給しよか",
    ]

    static let weekendKyoto: [String] = [
        "お休みの朝どすなぁ。のんびりお茶でも召し上がっておくれやす",
        "週末どすなぁ。ゆるりと水分補給しましょ",
    ]

    // MARK: - 季節メッセージ

    static let seasonalDefault: [String] = [
        "暑い日は特に水分補給が大切ですよ。こまめに飲みましょう",
    ]
}
