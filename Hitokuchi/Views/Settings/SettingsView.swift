import SwiftUI
import SwiftData

struct SettingsView: View {
    let storeManager: StoreManagerService

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: SettingsViewModel
    @State private var showingRestoreAlert = false
    @State private var showingFavoriteSelect = false

    init(storeManager: StoreManagerService) {
        self.storeManager = storeManager
        _viewModel = State(initialValue: SettingsViewModel(storeManager: storeManager))
    }

    var body: some View {
        List {
            // MARK: - Section 1: 目標
            Section(L("settings.section.goal")) {
                NavigationLink {
                    GoalSettingView(viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading, spacing: HitokuchiSpacing.xxs) {
                        Text(L("settings.goal.dailyAmount"))
                            .font(.body)
                            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                        Text(L("settings.goal.dailyAmountValue", viewModel.goalInCups, Int(viewModel.dailyGoalML)))
                            .font(.callout)
                            .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    }
                }
                .accessibilityLabel(L("a11y.settings.dailyAmount.label"))
                .accessibilityValue(L("a11y.settings.dailyAmount.value", Int(viewModel.dailyGoalML), viewModel.goalInCups))
                .accessibilityHint(L("a11y.settings.dailyAmount.hint"))

                NavigationLink {
                    QuietHoursView(viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading, spacing: HitokuchiSpacing.xxs) {
                        Text(L("settings.goal.quietHours"))
                            .font(.body)
                            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                        Text(L("settings.goal.quietHoursValue", viewModel.quietHourStart, viewModel.quietHourEnd))
                            .font(.callout)
                            .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    }
                }
                .accessibilityLabel(L("a11y.settings.quietHours.label"))
                .accessibilityValue(L("a11y.settings.quietHours.value", viewModel.quietHourStart, viewModel.quietHourEnd))
                .accessibilityHint(L("a11y.settings.quietHours.hint"))
            }

            // MARK: - Section 2: お楽しみ
            Section(L("settings.section.fun")) {
                NavigationLink {
                    ThemePickerView(viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading, spacing: HitokuchiSpacing.xxs) {
                        Text(L("settings.fun.theme"))
                            .font(.body)
                            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                        Text(L("settings.fun.themeValue", viewModel.selectedTheme.displayName))
                            .font(.callout)
                            .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    }
                }
                .accessibilityLabel(L("settings.fun.theme"))
                .accessibilityValue(viewModel.selectedTheme.displayName)
                .accessibilityHint(L("a11y.settings.theme.hint"))

                NavigationLink {
                    VoicePackView(viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading, spacing: HitokuchiSpacing.xxs) {
                        Text(L("settings.fun.voicePack"))
                            .font(.body)
                            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                        Text(L("settings.fun.voicePackValue", viewModel.messageTone.displayName))
                            .font(.callout)
                            .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    }
                }
                .accessibilityLabel(L("settings.fun.voicePack"))
                .accessibilityValue(viewModel.messageTone.displayName)
                .accessibilityHint(L("a11y.settings.voicePack.hint"))

                if !viewModel.isPremium {
                    NavigationLink {
                        PremiumView(storeManager: storeManager)
                    } label: {
                        HStack(spacing: HitokuchiSpacing.xs) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                            VStack(alignment: .leading, spacing: HitokuchiSpacing.xxs) {
                                Text(L("settings.fun.premium"))
                                    .font(.body)
                                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                                Text(L("settings.fun.premiumDescription"))
                                    .font(.callout)
                                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                            }
                        }
                    }
                    .accessibilityLabel(L("settings.fun.premium"))
                    .accessibilityHint(L("a11y.settings.premium.hint"))
                }
            }

            // MARK: - Section 4: 連携
            Section(L("settings.section.integration")) {
                Toggle(isOn: Binding(
                    get: { viewModel.healthKitEnabled },
                    set: { _ in
                        Task {
                            await viewModel.toggleHealthKit()
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: HitokuchiSpacing.xxs) {
                        Text(L("settings.integration.healthKit"))
                            .font(.body)
                            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                        Text(L("settings.integration.healthKitDescription"))
                            .font(.footnote)
                            .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                    }
                }
                .tint(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                .accessibilityLabel(L("a11y.settings.healthKit.label"))
                .accessibilityValue(viewModel.healthKitEnabled ? L("a11y.settings.numericValues.on") : L("a11y.settings.numericValues.off"))
                .accessibilityHint(L("a11y.settings.healthKit.hint"))
            }

            // MARK: - Section 5: 言語
            Section(L("settings.section.language")) {
                Picker(selection: Binding(
                    get: { viewModel.preferredLanguage },
                    set: { viewModel.preferredLanguage = $0 }
                )) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Text(language.displayName).tag(language)
                    }
                } label: {
                    Text(L("settings.language.displayLanguage"))
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                }
            }

            // MARK: - Section 6: サポート
            Section {
                NavigationLink {
                    FavoriteEditView()
                } label: {
                    Text(L("settings.support.editFavorites"))
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                }
                .accessibilityLabel(L("settings.support.editFavorites"))
                .accessibilityHint(L("a11y.settings.editFavorites.hint"))

                Button {
                    Task {
                        await viewModel.restorePurchases()
                        showingRestoreAlert = true
                    }
                } label: {
                    if viewModel.isRestoringPurchases {
                        HStack(spacing: HitokuchiSpacing.xs) {
                            ProgressView()
                            Text(L("settings.support.restoring"))
                                .font(.body)
                                .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                        }
                    } else {
                        Text(L("settings.support.restorePurchases"))
                            .font(.body)
                            .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    }
                }
                .disabled(viewModel.isRestoringPurchases)
                .accessibilityLabel(L("a11y.settings.restorePurchases.label"))
                .accessibilityHint(L("a11y.settings.restorePurchases.hint"))

                NavigationLink {
                    AboutView()
                } label: {
                    Text(L("settings.support.about"))
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                }
            }

            // MARK: - Footer
            Section {
                EmptyView()
            } footer: {
                Text(L("settings.footer.version",
                    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))
                    .font(.footnote)
                    .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("settings.title"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadSettings(context: modelContext)
        }
        .alert(L("settings.alert.restoreTitle"), isPresented: $showingRestoreAlert) {
            Button(L("common.ok")) {
                viewModel.restoreMessage = nil
            }
        } message: {
            Text(viewModel.restoreMessage ?? "")
        }
    }
}

// MARK: - Favorite Edit View (re-use of onboarding selection)

struct FavoriteEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = OnboardingViewModel()
    @State private var isInitialized = false

    var body: some View {
        ScrollView {
            VStack(spacing: HitokuchiSpacing.l) {
                Text(L("favoriteEdit.instruction"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.top, HitokuchiSpacing.l)

                Text(L("favoriteEdit.selectionCount", viewModel.selectedCount))
                    .font(.callout)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))

                beverageGrid

                HitokuchiPrimaryButton(label: L("favoriteEdit.saveButton")) {
                    viewModel.complete(context: modelContext)
                    dismiss()
                }
                .disabled(!viewModel.canProceed)
                .opacity(viewModel.canProceed ? 1.0 : 0.4)
                .padding(.horizontal, HitokuchiLayout.pageMargin)
            }
            .padding(.bottom, HitokuchiSpacing.xl)
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("favoriteEdit.title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadBeverages(context: modelContext)
            if !isInitialized {
                // Load current favorites
                let descriptor = FetchDescriptor<UserSettings>()
                if let settings = try? modelContext.fetch(descriptor).first {
                    viewModel.selectedBeverageIDs = Set(settings.favoriteBeverageIDs)
                }
                isInitialized = true
            }
        }
    }

    private var beverageGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: HitokuchiSpacing.s),
            GridItem(.flexible(), spacing: HitokuchiSpacing.s),
            GridItem(.flexible(), spacing: HitokuchiSpacing.s)
        ]

        return LazyVGrid(columns: columns, spacing: HitokuchiSpacing.s) {
            ForEach(viewModel.beverages, id: \.id) { beverage in
                beverageChip(beverage)
            }
        }
        .padding(.horizontal, HitokuchiLayout.pageMargin)
    }

    @ViewBuilder
    private func beverageChip(_ beverage: BeverageMaster) -> some View {
        let isSelected = viewModel.selectedBeverageIDs.contains(beverage.id)

        Button {
            viewModel.toggleBeverage(beverage.id)
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

// MARK: - About View

struct AboutView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            Section {
                HStack {
                    Text(L("about.version"))
                    Spacer()
                    Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                }

                HStack {
                    Text(L("about.supportedOS"))
                    Spacer()
                    Text("iOS 17+")
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                }
            }

            Section {
                Link(L("about.termsOfService"), destination: URL(string: "https://hitokuchi.app/terms")!)
                Link(L("about.privacyPolicy"), destination: URL(string: "https://hitokuchi.app/privacy")!)
            }

            Section {
                VStack(alignment: .center, spacing: HitokuchiSpacing.xs) {
                    Image(systemName: "drop.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                    Text(L("about.appName"))
                        .font(.headline)
                    Text(L("about.appTagline"))
                        .font(.callout)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HitokuchiSpacing.m)
            }

            // MARK: - 免責事項
            Section(L("about.disclaimerSection")) {
                Text(L("about.disclaimer"))
                    .font(.caption)
                    .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                    .accessibilityLabel(L("a11y.about.disclaimer"))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("about.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
