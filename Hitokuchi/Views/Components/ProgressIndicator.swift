import SwiftUI

struct ProgressIndicator: View {
    let stage: ProgressStage
    let percentage: Double
    let currentML: Double
    let goalML: Double
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: HitokuchiSpacing.xs) {
            // Progress text + ml display
            HStack(alignment: .lastTextBaseline) {
                Text(stage.displayText)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(stageColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                HStack(spacing: 0) {
                    Text(L("common.volumeFormat", Int(currentML)))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(stageColor)
                        .contentTransition(.numericText(value: currentML))
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: currentML)

                    Text(" / " + L("common.volumeFormat", Int(goalML)))
                        .font(.callout)
                        .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme))
                        .frame(height: HitokuchiLayout.progressBarHeight)

                    Capsule()
                        .fill(stageColor)
                        .frame(
                            width: max(HitokuchiLayout.progressBarHeight,
                                       geometry.size.width * min(percentage, 1.0)),
                            height: HitokuchiLayout.progressBarHeight
                        )
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.6), value: percentage)
                }
            }
            .frame(height: HitokuchiLayout.progressBarHeight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L("a11y.progress.label"))
        .accessibilityValue(accessibilityValueText)
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var stageColor: Color {
        switch stage {
        case .notStarted:
            return Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme)
        case .beginning, .onTrack:
            return Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme)
        case .almostDone, .achieved, .exceeded:
            return Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme)
        }
    }

    private var accessibilityValueText: String {
        let pct = Int(percentage * 100)
        return L("a11y.progress.valueWithoutNumeric", stage.displayText, pct)
    }
}
