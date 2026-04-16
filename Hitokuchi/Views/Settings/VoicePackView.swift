import SwiftUI

struct VoicePackView: View {
    @Bindable var viewModel: SettingsViewModel

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var purchasingTone: MessageTone?
    @State private var purchaseError: StoreError?
    @State private var showingError = false

    var body: some View {
        ScrollView {
            VStack(spacing: HitokuchiSpacing.l) {
                Text(L("voicePack.question"))
                    .font(.title3)
                    .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.top, HitokuchiSpacing.l)

                ForEach(MessageTone.allCases, id: \.self) { tone in
                    voicePackCard(tone)
                }
            }
            .padding(.horizontal, HitokuchiLayout.pageMargin)
            .padding(.bottom, HitokuchiSpacing.xl)
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .navigationTitle(L("voicePack.title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(L("store.error.title"), isPresented: $showingError) {
            Button(L("common.ok")) { purchaseError = nil }
        } message: {
            Text(purchaseError?.localizedMessage ?? "")
        }
    }

    // MARK: - Voice Pack Card

    @ViewBuilder
    private func voicePackCard(_ tone: MessageTone) -> some View {
        let isCurrent = viewModel.messageTone == tone
        let isUnlocked = tone.productID == nil || viewModel.storeManager.isVoicePackUnlocked(tone)

        VStack(alignment: .leading, spacing: HitokuchiSpacing.s) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: HitokuchiSpacing.xxxs) {
                    Text(tone.displayName)
                        .font(.headline)
                        .foregroundStyle(Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme))

                    Text(tone.toneDescription)
                        .font(.callout)
                        .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                }

                Spacer()

                if isCurrent {
                    Text(L("voicePack.inUse"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme))
                        .padding(.horizontal, HitokuchiSpacing.xs)
                        .padding(.vertical, HitokuchiSpacing.xxxs)
                        .background(Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme).opacity(0.1))
                        .clipShape(Capsule())
                } else if !isUnlocked {
                    if let product = viewModel.storeManager.product(for: tone.productID ?? "") {
                        Text(product.displayPrice)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                    }
                }
            }

            // Example messages
            VStack(alignment: .leading, spacing: HitokuchiSpacing.xs) {
                ForEach(exampleMessages(for: tone), id: \.self) { message in
                    HStack(alignment: .top, spacing: HitokuchiSpacing.xs) {
                        Text(L("voicePack.exampleLabel"))
                            .font(.caption)
                            .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                            .frame(width: 20, alignment: .leading)

                        Text(L("voicePack.exampleFormat", message))
                            .font(.callout)
                            .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(L("a11y.voicePack.exampleMessage", message))
                }
            }

            // Action button
            if isCurrent {
                // Already selected, no action needed
            } else if isUnlocked {
                Button {
                    viewModel.messageTone = tone
                } label: {
                    Text(L("voicePack.selectButton"))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.hitokuchi.fillButton(for: theme, colorScheme: colorScheme))
                        .clipShape(Capsule())
                }
                .accessibilityHint(L("a11y.voicePack.selectHint"))
            } else {
                Button {
                    guard let productID = tone.productID,
                          let product = viewModel.storeManager.product(for: productID) else { return }
                    Task {
                        purchasingTone = tone
                        do {
                            _ = try await viewModel.storeManager.purchase(product)
                            viewModel.messageTone = tone
                        } catch let error as StoreError where error != .userCancelled {
                            purchaseError = error
                            showingError = true
                        } catch {
                            // User cancelled
                        }
                        purchasingTone = nil
                    }
                } label: {
                    if purchasingTone == tone {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.hitokuchi.fillButton(for: theme, colorScheme: colorScheme))
                            .clipShape(Capsule())
                    } else if let product = viewModel.storeManager.product(for: tone.productID ?? "") {
                        Text(L("voicePack.purchaseButton", product.displayPrice))
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.hitokuchi.fillButton(for: theme, colorScheme: colorScheme))
                            .clipShape(Capsule())
                    }
                }
                .disabled(purchasingTone != nil)
                .accessibilityLabel(L("a11y.voicePack.purchaseLabel", tone.displayName, viewModel.storeManager.product(for: tone.productID ?? "")?.displayPrice ?? ""))
                .accessibilityHint(L("a11y.voicePack.purchaseHint"))
            }
        }
        .padding(HitokuchiSpacing.m)
        .background(
            isCurrent
                ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme).opacity(0.06)
                : Color.hitokuchi.bgSecondary(for: theme, colorScheme: colorScheme)
        )
        .clipShape(RoundedRectangle(cornerRadius: HitokuchiRadius.m))
        .overlay(
            RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                .stroke(
                    isCurrent
                        ? Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme)
                        : Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme),
                    lineWidth: isCurrent ? 1.5 : 1
                )
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Example Messages

    private func exampleMessages(for tone: MessageTone) -> [String] {
        switch tone {
        case .default:
            return [
                L("voicePack.example.default.1"),
                L("voicePack.example.default.2"),
                L("voicePack.example.default.3")
            ]
        case .kansai:
            return [
                L("voicePack.example.kansai.1"),
                L("voicePack.example.kansai.2"),
                L("voicePack.example.kansai.3")
            ]
        case .kyoto:
            return [
                L("voicePack.example.kyoto.1"),
                L("voicePack.example.kyoto.2"),
                L("voicePack.example.kyoto.3")
            ]
        }
    }
}
