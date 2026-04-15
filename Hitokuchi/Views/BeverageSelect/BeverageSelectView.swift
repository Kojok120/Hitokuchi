import SwiftUI
import SwiftData

struct BeverageSelectView: View {
    let homeViewModel: HomeViewModel
    let storeManager: StoreManagerService

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = BeverageSelectViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: HitokuchiSpacing.m) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HitokuchiSpacing.xs) {
                        categoryChip(nil, label: L("beverageSelect.filter.all"))
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            categoryChip(category, label: category.displayName)
                        }
                    }
                    .padding(.horizontal, HitokuchiLayout.pageMargin)
                }

                // Beverage List
                LazyVStack(spacing: HitokuchiSpacing.xs) {
                    ForEach(viewModel.groupedBeverages, id: \.category) { group in
                        Section {
                            ForEach(group.items, id: \.id) { beverage in
                                beverageRow(beverage)
                            }
                        } header: {
                            if viewModel.selectedCategory == nil {
                                Text(group.category.displayName)
                                    .font(.headline)
                                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, HitokuchiLayout.pageMargin)
                                    .padding(.top, HitokuchiSpacing.s)
                            }
                        }
                    }
                }
                .padding(.bottom, HitokuchiSpacing.xl)
            }
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("beverageSelect.title"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadBeverages(context: modelContext)
        }
    }

    // MARK: - Category Chip

    @ViewBuilder
    private func categoryChip(_ category: BeverageCategory?, label: String) -> some View {
        let isSelected = viewModel.selectedCategory == category
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedCategory = category
            }
        } label: {
            Text(label)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(
                    isSelected
                        ? .white
                        : Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme)
                )
                .padding(.horizontal, HitokuchiSpacing.m)
                .padding(.vertical, HitokuchiSpacing.xs)
                .background(
                    isSelected
                        ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme)
                        : Color.hitokuchi.bgSecondary(for: theme, colorScheme: colorScheme)
                )
                .clipShape(Capsule())
                .overlay(
                    isSelected
                        ? nil
                        : Capsule().stroke(Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme), lineWidth: 1)
                )
        }
        .accessibilityLabel(L("a11y.beverageSelect.category", label))
        .accessibilityValue(isSelected ? L("a11y.beverageSelect.categorySelected") : "")
        .accessibilityHint(isSelected ? "" : L("a11y.beverageSelect.categoryHint"))
    }

    // MARK: - Beverage Row

    @ViewBuilder
    private func beverageRow(_ beverage: BeverageMaster) -> some View {
        let isExpanded = viewModel.expandedBeverageID == beverage.id

        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                    viewModel.selectBeverage(beverage)
                }
            } label: {
                HStack(spacing: HitokuchiSpacing.s) {
                    // Category icon
                    Image(systemName: beverage.category.iconName)
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                        .frame(width: 32, height: 32)
                        .background(Color.hitokuchi.bgTertiary(for: theme, colorScheme: colorScheme))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: HitokuchiSpacing.xxxs) {
                        Text(beverage.localizedName)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))

                        HStack(spacing: HitokuchiSpacing.xs) {
                            let defaultAmount = DrinkAmount.defaultAmount(for: beverage.category)
                            Text("\(defaultAmount.displayName) (\(Int(defaultAmount.volumeML))ml)")
                                .font(.callout)
                                .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))

                            if beverage.hasCaffeine {
                                Text(L("beverageSelect.caffeineNote"))
                                    .font(.caption)
                                    .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                            }
                        }
                    }

                    Spacer()

                    if !isExpanded {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                    }
                }
                .padding(.horizontal, HitokuchiLayout.pageMargin)
                .padding(.vertical, HitokuchiSpacing.s)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(beverage.localizedName)
            .accessibilityHint(L("a11y.beverageSelect.beverageHint"))

            // Amount picker (expanded)
            if isExpanded {
                amountPicker(for: beverage)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            isExpanded
                ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme).opacity(0.05)
                : Color.clear
        )
        .overlay(
            isExpanded
                ? RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                    .stroke(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme), lineWidth: 1)
                : nil
        )
        .clipShape(RoundedRectangle(cornerRadius: isExpanded ? HitokuchiRadius.m : 0))
        .padding(.horizontal, isExpanded ? HitokuchiSpacing.xs : 0)
    }

    // MARK: - Amount Picker

    @ViewBuilder
    private func amountPicker(for beverage: BeverageMaster) -> some View {
        VStack(spacing: HitokuchiSpacing.s) {
            Text(L("beverageSelect.amountPicker.title"))
                .font(.callout)
                .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Amount chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HitokuchiSpacing.xs) {
                    ForEach(DrinkAmount.allCases, id: \.self) { amount in
                        amountChip(amount)
                    }
                }
            }

            // Record button
            Button {
                guard let amount = viewModel.selectedAmount else { return }
                Task {
                    await homeViewModel.recordDrink(
                        beverage: beverage,
                        amount: amount,
                        context: modelContext
                    )
                    dismiss()
                }
            } label: {
                Text(L("beverageSelect.button.record"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.hitokuchi.fillButton(for: theme, colorScheme: colorScheme))
                    .clipShape(Capsule())
            }
            .accessibilityLabel(L("beverageSelect.button.record"))
            .accessibilityHint(L("a11y.beverageSelect.recordHint"))
            .sensoryFeedback(.success, trigger: viewModel.isRecording)
        }
        .padding(.horizontal, HitokuchiLayout.pageMargin)
        .padding(.bottom, HitokuchiSpacing.m)
    }

    @ViewBuilder
    private func amountChip(_ amount: DrinkAmount) -> some View {
        let isSelected = viewModel.selectedAmount == amount

        Button {
            viewModel.selectAmount(amount)
        } label: {
            VStack(spacing: HitokuchiSpacing.xxxs) {
                Image(systemName: amount.iconName)
                    .font(.body)

                Text(amount.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("\(Int(amount.volumeML))ml")
                    .font(.caption2)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
            }
            .frame(width: 72, height: 72)
            .background(
                isSelected
                    ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme).opacity(0.15)
                    : Color.hitokuchi.bgTertiary(for: theme, colorScheme: colorScheme)
            )
            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
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
        }
        .buttonStyle(.plain)
        .accessibilityLabel(amount.displayName)
        .accessibilityValue(isSelected ? L("a11y.beverageSelect.amountSelected") : L("a11y.beverageSelect.amountValue", Int(amount.volumeML)))
        .accessibilityHint(isSelected ? "" : L("a11y.beverageSelect.amountHint"))
    }
}
