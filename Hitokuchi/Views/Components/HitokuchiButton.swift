import SwiftUI

struct HitokuchiPrimaryButton: View {
    let label: String
    var isLoading: Bool = false
    let action: () -> Void

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(label)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56)
        }
        .background(Color.hitokuchi.fillButton(for: theme, colorScheme: colorScheme))
        .clipShape(Capsule())
        .accessibilityLabel(label)
    }
}

struct HitokuchiSecondaryButton: View {
    let label: String
    var iconName: String?
    let action: () -> Void

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: HitokuchiSpacing.xs) {
                if let iconName {
                    Image(systemName: iconName)
                }
                Text(label)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
            .frame(maxWidth: .infinity, minHeight: 48)
            .overlay(
                Capsule()
                    .stroke(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme), lineWidth: 1.5)
            )
        }
        .accessibilityLabel(label)
    }
}

struct QuickRecordButton: View {
    let beverage: BeverageMaster
    let isRecorded: Bool
    let action: () -> Void

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: HitokuchiSpacing.xxs) {
                if isRecorded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: beverage.category.iconName)
                        .font(.title2)
                        .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                }

                Text(beverage.localizedName)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(DrinkAmount.defaultAmount(for: beverage.category).displayName)
                    .font(.caption2)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: HitokuchiLayout.quickRecordGridHeight)
            .background(
                isRecorded
                    ? Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme).opacity(0.1)
                    : Color.hitokuchi.bgSecondary(for: theme, colorScheme: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: HitokuchiRadius.m))
            .overlay(
                RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                    .stroke(
                        isRecorded
                            ? Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme)
                            : Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(reduceMotion ? nil : .spring(dampingFraction: 0.7), value: isPressed)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: isRecorded)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: isRecorded)
        .accessibilityLabel(L("a11y.home.quickRecord.label", beverage.localizedName))
        .accessibilityValue(DrinkAmount.defaultAmount(for: beverage.category).accessibilityLabel)
        .accessibilityHint(L("a11y.home.quickRecord.hint"))
        .accessibilityAddTraits(.isButton)
    }
}
