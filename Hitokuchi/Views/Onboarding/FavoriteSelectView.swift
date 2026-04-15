import SwiftUI
import SwiftData

struct FavoriteSelectView: View {
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel = OnboardingViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: HitokuchiSpacing.xxl)

            // Title
            Text(L("favoriteSelect.title"))
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Spacer().frame(height: HitokuchiSpacing.xs)

            Text(L("favoriteSelect.subtitle"))
                .font(.body)
                .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            Spacer().frame(height: HitokuchiSpacing.l)

            // Beverage grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.beverages, id: \.id) { beverage in
                        beverageChip(beverage)
                    }
                }
                .padding(.horizontal, HitokuchiLayout.pageMargin)
            }

            Spacer().frame(height: HitokuchiSpacing.s)

            // Selection counter
            Text(L("favoriteSelect.selectionCount", viewModel.selectedCount))
                .font(.callout)
                .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                .accessibilityLabel(L("a11y.favoriteSelect.selectionCount", viewModel.selectedCount))

            Spacer().frame(height: HitokuchiSpacing.m)

            // Complete button
            HitokuchiPrimaryButton(label: L("favoriteSelect.completeButton")) {
                viewModel.complete(context: modelContext)
                onComplete()
            }
            .disabled(!viewModel.canProceed)
            .opacity(viewModel.canProceed ? 1.0 : 0.4)
            .padding(.horizontal, HitokuchiLayout.pageMargin)
            .accessibilityLabel(L("a11y.favoriteSelect.completeLabel"))
            .accessibilityHint(viewModel.canProceed ? L("a11y.favoriteSelect.completeHint") : "")

            Spacer().frame(height: HitokuchiSpacing.xl)
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .onAppear {
            viewModel.loadBeverages(context: modelContext)
        }
    }

    // MARK: - Beverage Chip

    @ViewBuilder
    private func beverageChip(_ beverage: BeverageMaster) -> some View {
        let isSelected = viewModel.selectedBeverageIDs.contains(beverage.id)

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleBeverage(beverage.id)
            }
        } label: {
            VStack(spacing: HitokuchiSpacing.xxs) {
                Image(systemName: beverage.category.iconName)
                    .font(.body)
                    .foregroundStyle(
                        isSelected
                            ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme)
                            : Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme)
                    )

                Text(beverage.localizedName)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                isSelected
                    ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme).opacity(0.1)
                    : Color.hitokuchi.bgSecondary(for: theme, colorScheme: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: HitokuchiRadius.m))
            .overlay(
                RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                    .stroke(
                        isSelected
                            ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme)
                            : Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                        .padding(HitokuchiSpacing.xxs)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.warning, trigger: viewModel.selectedCount == 5 && !isSelected)
        .accessibilityLabel(beverage.localizedName)
        .accessibilityValue(isSelected ? L("a11y.favoriteSelect.selected") : L("a11y.favoriteSelect.notSelected"))
        .accessibilityHint(isSelected ? L("a11y.favoriteSelect.deselectHint") : L("a11y.favoriteSelect.selectHint"))
    }
}
