import Foundation

/// メッセージの語り口調。デフォルトは無料、方言トーンはIAP。
enum MessageTone: String, CaseIterable, Codable, Sendable {
    case `default` = "default"
    case kansai = "kansai"
    case kyoto = "kyoto"

    var productID: String? {
        switch self {
        case .default: return nil
        case .kansai:  return "hitokuchi.voice.kansai"
        case .kyoto:   return "hitokuchi.voice.kyoto"
        }
    }

    @MainActor
    var displayName: String {
        switch self {
        case .default: return L("messageTone.default.name")
        case .kansai:  return L("messageTone.kansai.name")
        case .kyoto:   return L("messageTone.kyoto.name")
        }
    }

    @MainActor
    var toneDescription: String {
        switch self {
        case .default: return L("messageTone.default.description")
        case .kansai:  return L("messageTone.kansai.description")
        case .kyoto:   return L("messageTone.kyoto.description")
        }
    }
}
