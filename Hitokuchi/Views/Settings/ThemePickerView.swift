import SwiftUI

struct ThemePickerView: View {
    @Bindable var viewModel: SettingsViewModel

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var previewTheme: AppTheme?
    @State private var previewTimer: Task<Void, Never>?
    @State private var isPurchasing = false
    @State private var purchaseError: StoreError?
    @State private var showingError = false

    private var activeTheme: AppTheme { previewTheme ?? theme }

    var body: some View {
        ScrollView {
            VStack(spacing: HitokuchiSpacing.s) {
                ForEach(AppTheme.allCases, id: \.self) { appTheme in
                    themeCard(appTheme)
                }
            }
            .padding(.horizontal, HitokuchiLayout.pageMargin)
            .padding(.top, HitokuchiSpacing.l)
            .padding(.bottom, HitokuchiSpacing.xl)
        }
        .background(Color.hitokuchi.bgPrimary(for: activeTheme, colorScheme: colorScheme))
        .navigationTitle(L("themePicker.title"))
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if let previewTheme {
                previewBar(theme: previewTheme)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: previewTheme)
        .alert(L("store.error.title"), isPresented: $showingError) {
            Button(L("common.ok")) { purchaseError = nil }
        } message: {
            Text(purchaseError?.localizedMessage ?? "")
        }
    }

    // MARK: - Theme Card

    @ViewBuilder
    private func themeCard(_ appTheme: AppTheme) -> some View {
        let isCurrent = viewModel.selectedTheme == appTheme
        let isUnlocked = appTheme.productID == nil || viewModel.storeManager.isThemeUnlocked(appTheme)

        Button {
            if isCurrent { return }
            if isUnlocked {
                viewModel.selectedTheme = appTheme
            } else {
                startPreview(appTheme)
            }
        } label: {
            HStack(spacing: HitokuchiSpacing.s) {
                // Theme accent dot
                Circle()
                    .fill(Color.hitokuchi.accentPrimary(for: appTheme, colorScheme: colorScheme))
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: HitokuchiSpacing.xxxs) {
                    Text(appTheme.displayName)
                        .font(.headline)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: activeTheme, colorScheme: colorScheme))

                    Text(appTheme.themeDescription)
                        .font(.callout)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: activeTheme, colorScheme: colorScheme))
                }

                Spacer()

                if isCurrent {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.hitokuchi.accentSuccess(for: activeTheme, colorScheme: colorScheme))
                } else if !isUnlocked {
                    if let product = viewModel.storeManager.product(for: appTheme.productID ?? "") {
                        Text(product.displayPrice)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.hitokuchi.accentPrimary(for: activeTheme, colorScheme: colorScheme))
                    } else {
                        ProgressView()
                    }
                }
            }
            .padding(HitokuchiSpacing.m)
            .frame(minHeight: 80)
            .background(
                isCurrent
                    ? Color.hitokuchi.accentPrimary(for: activeTheme, colorScheme: colorScheme).opacity(0.06)
                    : Color.hitokuchi.bgSecondary(for: activeTheme, colorScheme: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: HitokuchiRadius.m))
            .overlay(
                RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                    .stroke(
                        isCurrent
                            ? Color.hitokuchi.accentPrimary(for: activeTheme, colorScheme: colorScheme)
                            : Color.hitokuchi.borderDefault(for: activeTheme, colorScheme: colorScheme),
                        lineWidth: isCurrent ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(appTheme.displayName)
        .accessibilityValue(isCurrent ? L("a11y.themePicker.inUse") : (isUnlocked ? L("a11y.themePicker.available") : L("a11y.themePicker.locked")))
        .accessibilityHint(
            isCurrent ? "" : (isUnlocked ? L("a11y.themePicker.switchHint") : L("a11y.themePicker.previewHint"))
        )
    }

    // MARK: - Preview Bar

    @ViewBuilder
    private func previewBar(theme previewingTheme: AppTheme) -> some View {
        VStack(spacing: HitokuchiSpacing.xs) {
            Text(L("themePicker.previewMessage", previewingTheme.displayName))
                .font(.callout)
                .foregroundStyle(Color.hitokuchi.textPrimary(for: activeTheme, colorScheme: colorScheme))

            HStack(spacing: HitokuchiSpacing.s) {
                if let product = viewModel.storeManager.product(for: previewingTheme.productID ?? "") {
                    Button {
                        Task {
                            isPurchasing = true
                            do {
                                _ = try await viewModel.storeManager.purchase(product)
                                viewModel.selectedTheme = previewingTheme
                                cancelPreview()
                            } catch let error as StoreError where error != .userCancelled {
                                purchaseError = error
                                showingError = true
                            } catch {
                                // User cancelled
                            }
                            isPurchasing = false
                        }
                    } label: {
                        Text(L("themePicker.purchaseButton", product.displayPrice))
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, HitokuchiSpacing.m)
                            .padding(.vertical, HitokuchiSpacing.xs)
                            .background(Color.hitokuchi.fillButton(for: activeTheme, colorScheme: colorScheme))
                            .clipShape(Capsule())
                    }
                    .disabled(isPurchasing)
                    .accessibilityLabel(L("a11y.themePicker.purchaseLabel", product.displayPrice))
                    .accessibilityHint(L("a11y.themePicker.purchaseHint"))
                }

                Button {
                    cancelPreview()
                } label: {
                    Text(L("themePicker.backButton"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: activeTheme, colorScheme: colorScheme))
                        .padding(.horizontal, HitokuchiSpacing.m)
                        .padding(.vertical, HitokuchiSpacing.xs)
                }
                .accessibilityLabel(L("a11y.themePicker.endPreview"))
            }
        }
        .padding(HitokuchiSpacing.m)
        .background(
            Color.hitokuchi.bgSecondary(for: activeTheme, colorScheme: colorScheme)
                .shadow(radius: 8, y: -2)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(L("a11y.themePicker.previewLabel", previewingTheme.displayName, previewingTheme.themeDescription))
    }

    // MARK: - Preview Logic

    private func startPreview(_ appTheme: AppTheme) {
        cancelPreview()
        previewTheme = appTheme
        // Auto-revert after 5 seconds
        previewTimer = Task {
            try? await Task.sleep(for: .seconds(5))
            if !Task.isCancelled {
                await MainActor.run {
                    cancelPreview()
                }
            }
        }
    }

    private func cancelPreview() {
        previewTimer?.cancel()
        previewTimer = nil
        previewTheme = nil
    }
}
