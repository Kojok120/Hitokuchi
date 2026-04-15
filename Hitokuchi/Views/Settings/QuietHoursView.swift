import SwiftUI

struct QuietHoursView: View {
    @Bindable var viewModel: SettingsViewModel

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    // DatePickers need Date binding; convert hour Int to Date
    private var startDate: Binding<Date> {
        Binding(
            get: { dateFrom(hour: viewModel.quietHourStart) },
            set: { viewModel.quietHourStart = hourFrom(date: $0) }
        )
    }

    private var endDate: Binding<Date> {
        Binding(
            get: { dateFrom(hour: viewModel.quietHourEnd) },
            set: { viewModel.quietHourEnd = hourFrom(date: $0) }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: HitokuchiSpacing.xxl)

            Text(L("quietHours.description"))
                .font(.title2)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            Spacer().frame(height: HitokuchiSpacing.l)

            VStack(spacing: HitokuchiSpacing.m) {
                HStack {
                    Text(L("quietHours.start"))
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    Spacer()
                    DatePicker("", selection: startDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .accessibilityLabel(L("a11y.quietHours.startLabel"))
                        .accessibilityValue(L("a11y.quietHours.startValue", viewModel.quietHourStart))
                }

                HStack {
                    Text(L("quietHours.end"))
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    Spacer()
                    DatePicker("", selection: endDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .accessibilityLabel(L("a11y.quietHours.endLabel"))
                        .accessibilityValue(L("a11y.quietHours.endValue", viewModel.quietHourEnd))
                }
            }
            .padding(.horizontal, HitokuchiLayout.pageMargin)

            Spacer().frame(height: HitokuchiSpacing.m)

            Text(L("quietHours.summary", viewModel.quietHourStart, viewModel.quietHourEnd))
                .font(.footnote)
                .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("quietHours.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func dateFrom(hour: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private func hourFrom(date: Date) -> Int {
        Calendar.current.component(.hour, from: date)
    }
}
