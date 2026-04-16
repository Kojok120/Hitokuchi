import SwiftUI

/// ImageRenderer用のシェアカード。@Environmentは使用不可のため、値を直接受け取る。
struct ShareCardView: View {
    let progress: HydrationProgress
    let streakDays: Int
    let colors: ThemeColorSet

    private var percentageText: String {
        "\(min(Int(progress.percentage), 999))%"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top — App branding
            HStack {
                Image(systemName: "drop.fill")
                    .font(.caption)
                Text("ひとくち")
                    .font(.callout)
                    .fontWeight(.medium)
            }
            .foregroundStyle(colors.textTertiary)
            .padding(.top, 32)

            Spacer()

            // Center — Progress ring
            ZStack {
                Circle()
                    .stroke(colors.borderDefault, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: min(CGFloat(progress.ratio), 1.0))
                    .stroke(
                        progress.isGoalAchieved ? colors.accentSuccess : colors.accentPrimary,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text(percentageText)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(colors.textPrimary)
                    Text("\(Int(progress.totalML)) / \(Int(progress.goalML)) ml")
                        .font(.callout)
                        .foregroundStyle(colors.textSecondary)
                }
            }
            .frame(width: 200, height: 200)

            Spacer()

            // Bottom — Streak (if any)
            if streakDays > 0 {
                VStack(spacing: 2) {
                    Text("\(streakDays)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(colors.accentPrimary)
                    Text("streak")
                        .font(.caption)
                        .foregroundStyle(colors.textTertiary)
                }
            }

            Spacer().frame(height: 32)
        }
        .frame(width: 540, height: 540)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colors.bgPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [colors.accentPrimary.opacity(0.05), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(colors.borderDefault, lineWidth: 1)
                )
        )
    }
}
