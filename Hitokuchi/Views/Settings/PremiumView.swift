import SwiftUI
import StoreKit

struct PremiumView: View {
    let storeManager: StoreManagerService

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false

    private var premiumProduct: Product? {
        storeManager.product(for: "hitokuchi.premium")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: HitokuchiSpacing.xxl)

                // Catch copy
                Text(L("premium.catchCopy"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    .multilineTextAlignment(.center)

                Spacer().frame(height: HitokuchiSpacing.m)

                Text(L("premium.subtitle"))
                    .font(.body)
                    .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    .multilineTextAlignment(.center)

                Spacer().frame(height: HitokuchiSpacing.l)

                // Feature cards
                VStack(spacing: HitokuchiSpacing.s) {
                    featureCard(
                        icon: "leaf.fill",
                        title: L("premium.feature.seasonal.title"),
                        description: L("premium.feature.seasonal.description")
                    )

                    featureCard(
                        icon: "chart.bar.fill",
                        title: L("premium.feature.insights.title"),
                        description: L("premium.feature.insights.description")
                    )

                    featureCard(
                        icon: "paintpalette.fill",
                        title: L("premium.feature.themes.title"),
                        description: L("premium.feature.themes.description")
                    )
                }
                .padding(.horizontal, HitokuchiLayout.pageMargin)

                Spacer().frame(height: HitokuchiSpacing.xl)

                // Purchase button
                if let product = premiumProduct {
                    Button {
                        Task {
                            isPurchasing = true
                            do {
                                _ = try await storeManager.purchase(product)
                                dismiss()
                            } catch {
                                // User cancelled or error
                            }
                            isPurchasing = false
                        }
                    } label: {
                        Group {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(L("premium.purchaseButton", product.displayPrice))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.hitokuchi.fillButton(for: theme, colorScheme: colorScheme))
                        .clipShape(Capsule())
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal, HitokuchiLayout.pageMargin)
                    .accessibilityLabel(L("a11y.premium.purchaseLabel", product.displayPrice))
                    .accessibilityValue(L("a11y.premium.purchaseValue"))
                    .accessibilityHint(L("a11y.premium.purchaseHint"))
                } else if storeManager.products.isEmpty {
                    Text(L("premium.oneTimePurchaseNote"))
                        .font(.callout)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ProgressView()
                        .padding()
                }

                Spacer().frame(height: HitokuchiSpacing.xs)

                Text(L("premium.oneTimePurchaseNote"))
                    .font(.footnote)
                    .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                    .multilineTextAlignment(.center)

                Spacer().frame(height: HitokuchiSpacing.xl)
            }
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("premium.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Feature Card

    @ViewBuilder
    private func featureCard(icon: String, title: String, description: String) -> some View {
        HitokuchiCard {
            HStack(alignment: .top, spacing: HitokuchiSpacing.s) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: HitokuchiSpacing.xxxs) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))

                    Text(description)
                        .font(.body)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
