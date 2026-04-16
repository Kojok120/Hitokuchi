import SwiftUI

struct GoalSettingView: View {
    @Bindable var viewModel: SettingsViewModel

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: HitokuchiSpacing.xxl)

            Text(L("goalSetting.question"))
                .font(.title2)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            Spacer().frame(height: HitokuchiSpacing.l)

            // Display current goal in natural language
            VStack(spacing: HitokuchiSpacing.xxs) {
                Text(L("goalSetting.cupsDisplay", viewModel.goalInCups))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))

                Text(L("goalSetting.mlDisplay", Int(viewModel.dailyGoalML)))
                    .font(.title3)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(L("a11y.goalSetting.label"))
            .accessibilityValue(L("a11y.goalSetting.value", Int(viewModel.dailyGoalML), viewModel.goalInCups))

            Spacer().frame(height: HitokuchiSpacing.l)

            // Stepper
            Stepper(
                value: Binding(
                    get: { viewModel.dailyGoalML },
                    set: { viewModel.dailyGoalML = $0 }
                ),
                in: 500...5000,
                step: 250
            ) {
                Text(L("common.volumeFormat", Int(viewModel.dailyGoalML)))
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
            }
            .tint(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
            .padding(.horizontal, HitokuchiLayout.pageMargin)
            .accessibilityLabel(L("a11y.goalSetting.stepper.label"))
            .accessibilityValue(L("a11y.goalSetting.stepper.value", Int(viewModel.dailyGoalML)))
            .accessibilityHint(L("a11y.goalSetting.stepper.hint"))

            Spacer().frame(height: HitokuchiSpacing.m)

            Text(L("goalSetting.recommendation"))
                .font(.footnote)
                .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("goalSetting.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
