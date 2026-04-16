import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = HistoryViewModel()
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: HitokuchiSpacing.l) {
                // Segment Control
                Picker(L("a11y.history.segmentControl"), selection: $viewModel.selectedSegment) {
                    Text(L("history.segment.today")).tag(HistoryViewModel.HistorySegment.today)
                    Text(L("history.segment.thisWeek")).tag(HistoryViewModel.HistorySegment.thisWeek)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, HitokuchiLayout.pageMargin)
                .accessibilityLabel(L("a11y.history.segmentControl"))

                if viewModel.selectedSegment == .today {
                    todayView
                } else {
                    weekView
                }
            }
            .padding(.top, HitokuchiSpacing.m)
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("history.title"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadData(context: modelContext)
        }
        .sheet(isPresented: $showShareSheet) {
            sharePreviewSheet
        }
    }

    // MARK: - Share Preview Sheet

    private var sharePreviewSheet: some View {
        let colors = Color.hitokuchi.themeColors(theme, colorScheme)
        let streakDays = viewModel.streakDays

        return VStack(spacing: HitokuchiSpacing.l) {
            Text(L("history.share.preview.title"))
                .font(.headline)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                .padding(.top, HitokuchiSpacing.l)

            ShareCardView(
                progress: viewModel.todayProgress,
                streakDays: streakDays,
                date: .now,
                colors: colors
            )
            .frame(width: 270, height: 270)

            if let shareImage = generateShareImage(colors: colors, streakDays: streakDays) {
                ShareLink(
                    item: Image(uiImage: shareImage),
                    preview: SharePreview(L("history.share.preview.title"), image: Image(uiImage: shareImage))
                ) {
                    HStack(spacing: HitokuchiSpacing.xs) {
                        Image(systemName: "square.and.arrow.up")
                        Text(L("history.share.action"))
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.hitokuchi.fillButton(for: theme, colorScheme: colorScheme))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, HitokuchiLayout.pageMargin)
            }

            Spacer()
        }
        .presentationDetents([.medium])
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
    }

    private func generateShareImage(colors: ThemeColorSet, streakDays: Int) -> UIImage? {
        let renderer = ImageRenderer(
            content: ShareCardView(
                progress: viewModel.todayProgress,
                streakDays: streakDays,
                date: .now,
                colors: colors
            )
        )
        renderer.scale = 2.0
        return renderer.uiImage
    }

    // MARK: - Today

    private var todayView: some View {
        VStack(spacing: HitokuchiSpacing.l) {
            // Share button
            HStack {
                Spacer()
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(L("history.share.button"))
                .accessibilityHint(L("a11y.history.share.hint"))
            }
            .padding(.horizontal, HitokuchiLayout.pageMargin)
            .padding(.top, -HitokuchiSpacing.s)

            // Summary message
            MessageBubble(
                message: viewModel.todayMessage,
                style: .history
            )

            // Progress
            ProgressIndicator(
                stage: viewModel.todayProgress.stage,
                percentage: viewModel.todayProgress.ratio,
                currentML: viewModel.todayProgress.totalML,
                goalML: viewModel.todayProgress.goalML
            )
            .padding(.horizontal, HitokuchiLayout.pageMargin)

            // Today's log list
            if !viewModel.todayLogs.isEmpty {
                VStack(alignment: .leading, spacing: HitokuchiSpacing.xs) {
                    Text(L("history.section.todayLogs"))
                        .font(.headline)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                        .padding(.horizontal, HitokuchiLayout.pageMargin)

                    LazyVStack(spacing: HitokuchiSpacing.xxs) {
                        ForEach(viewModel.todayLogs, id: \.id) { log in
                            logRow(log)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Week

    private var weekView: some View {
        VStack(spacing: HitokuchiSpacing.l) {
            // Weekly message
            MessageBubble(
                message: viewModel.weeklyMessage,
                style: .weekly
            )

            // Week calendar bar
            weekCalendarBar

            // Daily summaries
            VStack(alignment: .leading, spacing: HitokuchiSpacing.xs) {
                Text(L("history.section.weeklySummary"))
                    .font(.headline)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    .padding(.horizontal, HitokuchiLayout.pageMargin)

                LazyVStack(spacing: HitokuchiSpacing.s) {
                    ForEach(viewModel.weekDays) { day in
                        daySummaryCard(day)
                    }
                }
                .padding(.horizontal, HitokuchiLayout.pageMargin)
            }
        }
    }

    // MARK: - Week Calendar Bar

    private var weekCalendarBar: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekDays) { day in
                VStack(spacing: HitokuchiSpacing.xxs) {
                    Text(day.dayName)
                        .font(.caption2)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))

                    Circle()
                        .fill(dotColor(for: day))
                        .frame(width: 12, height: 12)

                    if day.isToday {
                        Rectangle()
                            .fill(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                            .frame(width: 12, height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(day.dayName), \(day.summaryText)")
            }
        }
        .padding(.horizontal, HitokuchiLayout.pageMargin)
        .frame(height: 48)
    }

    private func dotColor(for day: HistoryViewModel.WeekDayData) -> Color {
        switch day.status {
        case .achieved:
            return Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme)
        case .partial:
            return Color.hitokuchi.accentWarning(for: theme, colorScheme: colorScheme)
        case .belowHalf, .noRecord:
            return Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme)
        }
    }

    // MARK: - Log Row

    @ViewBuilder
    private func logRow(_ log: DrinkLog) -> some View {
        HStack(spacing: HitokuchiSpacing.s) {
            Text(log.recordedAt, format: .dateTime.hour().minute())
                .font(.callout)
                .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                .frame(width: 50, alignment: .leading)

            Text(log.beverage?.localizedName ?? "")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))

            Spacer()

            VStack(alignment: .trailing) {
                Text(log.drinkAmount.displayName)
                    .font(.callout)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                Text(L("common.volumeFormat", Int(log.volumeML)))
                    .font(.caption)
                    .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
            }
        }
        .padding(.horizontal, HitokuchiLayout.pageMargin)
        .padding(.vertical, HitokuchiSpacing.s)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(log.recordedAt.formatted(.dateTime.hour().minute())), \(log.beverage?.localizedName ?? ""), \(log.drinkAmount.displayName), \(L("common.volumeFormat", Int(log.volumeML)))")
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteLog(log, context: modelContext)
            } label: {
                Label(L("history.delete"), systemImage: "trash")
            }
        }
    }

    // MARK: - Day Summary Card

    @ViewBuilder
    private func daySummaryCard(_ day: HistoryViewModel.WeekDayData) -> some View {
        HitokuchiCard {
            HStack {
                VStack(alignment: .leading, spacing: HitokuchiSpacing.xxs) {
                    Text(day.date, format: .dateTime.month().day().weekday())
                        .font(.headline)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                        .accessibilityAddTraits(.isHeader)

                    Text(day.summaryText)
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                }

                Spacer()

                Circle()
                    .fill(dotColor(for: day))
                    .frame(width: 12, height: 12)
            }
        }
    }
}
