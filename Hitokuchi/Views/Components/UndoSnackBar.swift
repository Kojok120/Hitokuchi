import SwiftUI

struct UndoSnackBar: View {
    let beverageName: String
    let secondsRemaining: Int
    let onUndo: () -> Void

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: HitokuchiSpacing.s) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundStyle(Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme))

            Text(L("home.undo.recorded", beverageName))
                .font(.subheadline)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                .lineLimit(1)

            Spacer()

            Button(action: onUndo) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.caption)
                    Text(L("home.undo.button"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
            }
            .accessibilityLabel(L("a11y.home.undo.label"))
            .accessibilityHint(L("a11y.home.undo.hint"))

            // Countdown arc
            ZStack {
                Circle()
                    .stroke(Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme), lineWidth: 2)
                Circle()
                    .trim(from: 0, to: CGFloat(secondsRemaining) / 5.0)
                    .stroke(
                        Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(secondsRemaining)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
            }
            .frame(width: 24, height: 24)
            .accessibilityHidden(true)
        }
        .padding(.horizontal, HitokuchiSpacing.m)
        .frame(height: 44)
        .background(
            Capsule()
                .fill(Color.hitokuchi.bgSecondary(for: theme, colorScheme: colorScheme))
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
        .padding(.horizontal, HitokuchiLayout.pageMargin)
    }
}
