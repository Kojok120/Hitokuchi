import SwiftUI

enum MessageStyle {
    case home
    case homeAchieved
    case history
    case weekly

    var font: Font {
        switch self {
        case .home, .homeAchieved: return .title
        case .history, .weekly: return .title2
        }
    }

    var fixedHeight: CGFloat {
        switch self {
        case .home, .homeAchieved: return 120
        case .history, .weekly: return 80
        }
    }

    var weight: Font.Weight {
        switch self {
        case .homeAchieved: return .semibold
        default: return .regular
        }
    }
}

struct MessageBubble: View {
    let message: String
    let style: MessageStyle
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(message)
            .font(style.font)
            .fontWeight(style.weight)
            .foregroundStyle(textColor)
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
            .padding(HitokuchiSpacing.l)
            .frame(maxWidth: .infinity, minHeight: style.fixedHeight, alignment: .topLeading)
            .accessibilityElement()
            .accessibilityLabel(message)
            .accessibilityAddTraits(.isStaticText)
            .contentTransition(.opacity)
    }

    private var textColor: Color {
        switch style {
        case .homeAchieved:
            return Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme)
        default:
            return Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme)
        }
    }
}
