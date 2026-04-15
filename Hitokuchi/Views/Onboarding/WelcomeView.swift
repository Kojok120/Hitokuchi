import SwiftUI

struct WelcomeView: View {
    let onNext: () -> Void

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: HitokuchiSpacing.xxxl)

            // App icon
            Image(systemName: "drop.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                .accessibilityHidden(true)

            Spacer().frame(height: HitokuchiSpacing.l)

            // Title
            Text(L("welcome.title"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Spacer().frame(height: HitokuchiSpacing.m)

            // Subtitle
            Text(L("welcome.subtitle"))
                .font(.title3)
                .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Spacer()

            // Feature list
            VStack(alignment: .leading, spacing: HitokuchiSpacing.s) {
                featureRow(L("welcome.feature.naturalLanguage"))
                featureRow(L("welcome.feature.oneButton"))
                featureRow(L("welcome.feature.voiceOver"))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(L("a11y.welcome.features"))

            Spacer()

            // Medical Disclaimer
            Text(L("about.disclaimer"))
                .font(.caption2)
                .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, HitokuchiLayout.pageMargin)
                .accessibilityLabel(L("a11y.about.disclaimer"))

            Spacer().frame(height: HitokuchiSpacing.m)

            // Start button
            HitokuchiPrimaryButton(label: L("welcome.startButton")) {
                onNext()
            }
            .padding(.horizontal, HitokuchiLayout.pageMargin)
            .accessibilityHint(L("a11y.welcome.startHint"))

            Spacer().frame(height: HitokuchiSpacing.xl)
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
    }

    @ViewBuilder
    private func featureRow(_ text: String) -> some View {
        HStack(spacing: HitokuchiSpacing.s) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundStyle(Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme))
                .frame(width: 20, height: 20)

            Text(text)
                .font(.body)
                .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
        }
        .padding(.horizontal, HitokuchiLayout.pageMargin)
    }
}
