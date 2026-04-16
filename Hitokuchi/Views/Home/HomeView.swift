import SwiftUI
import SwiftData

struct HomeView: View {
    let storeManager: StoreManagerService

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel = HomeViewModel()
    @State private var showCelebration = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: HitokuchiSpacing.xxl)

                // Message Bubble
                MessageBubble(
                    message: viewModel.currentMessage,
                    style: viewModel.progress.isGoalAchieved ? .homeAchieved : .home
                )

                Spacer().frame(height: HitokuchiSpacing.m)

                // Progress Indicator
                ProgressIndicator(
                    stage: viewModel.progress.stage,
                    percentage: viewModel.progress.ratio,
                    currentML: viewModel.progress.totalML,
                    goalML: viewModel.progress.goalML
                )
                .padding(.horizontal, HitokuchiLayout.pageMargin)

                Spacer().frame(height: HitokuchiSpacing.xxl)

                // Quick Record Section
                VStack(alignment: .leading, spacing: HitokuchiSpacing.s) {
                    HStack {
                        Text(L("home.section.favorites"))
                            .font(.headline)
                            .foregroundStyle(Color.hitokuchi.textSecondary(for: theme, colorScheme: colorScheme))
                        Spacer()
                        NavigationLink {
                            FavoriteEditView()
                        } label: {
                            Text(L("settings.support.editFavorites"))
                                .font(.callout)
                                .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                        }
                        .accessibilityLabel(L("settings.support.editFavorites"))
                        .accessibilityHint(L("a11y.settings.editFavorites.hint"))
                    }
                    .padding(.horizontal, HitokuchiLayout.pageMargin)

                    if viewModel.favoriteBeverages.isEmpty {
                        // Empty state
                        NavigationLink {
                            FavoriteEditView()
                        } label: {
                            HStack(spacing: HitokuchiSpacing.xs) {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                                Text(L("home.favorites.empty"))
                                    .font(.callout)
                            }
                            .foregroundStyle(Color.hitokuchi.textTertiary(for: theme, colorScheme: colorScheme))
                            .frame(maxWidth: .infinity, minHeight: HitokuchiLayout.quickRecordGridHeight)
                            .background(Color.hitokuchi.bgSecondary(for: theme, colorScheme: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: HitokuchiRadius.m))
                            .overlay(
                                RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 3]))
                                    .foregroundStyle(Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme))
                            )
                        }
                        .padding(.horizontal, HitokuchiLayout.pageMargin)
                        .accessibilityLabel(L("a11y.home.addFavorite"))
                        .accessibilityHint(L("a11y.home.addFavorite.hint"))
                    } else {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: HitokuchiSpacing.s), count: 3),
                            spacing: HitokuchiSpacing.s
                        ) {
                            ForEach(viewModel.favoriteBeverages, id: \.id) { beverage in
                                QuickRecordButton(
                                    beverage: beverage,
                                    isRecorded: viewModel.lastRecordedBeverageID == beverage.id
                                ) {
                                    Task {
                                        let amount = DrinkAmount.defaultAmount(for: beverage.category)
                                        await viewModel.recordDrink(
                                            beverage: beverage,
                                            amount: amount,
                                            context: modelContext
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, HitokuchiLayout.pageMargin)
                    }
                }

                Spacer().frame(height: HitokuchiSpacing.l)

                // "Other Beverages" Button
                NavigationLink {
                    BeverageSelectView(
                        homeViewModel: viewModel,
                        storeManager: storeManager
                    )
                } label: {
                    HStack(spacing: HitokuchiSpacing.xs) {
                        Image(systemName: "plus")
                        Text(L("home.button.otherBeverages"))
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme))
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .overlay(
                        Capsule()
                            .stroke(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, HitokuchiLayout.pageMargin)
                .accessibilityLabel(L("home.button.otherBeverages"))
                .accessibilityHint(L("a11y.home.otherBeverages.hint"))

                Spacer().frame(height: HitokuchiSpacing.xl)
            }
        }
        .background(Color.hitokuchi.bgPrimary(for: theme, colorScheme: colorScheme))
        .overlay {
            CelebrationEffect(
                isActive: showCelebration,
                color: Color.hitokuchi.accentSuccess(for: theme, colorScheme: colorScheme)
            )
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: showCelebration)
        .overlay(alignment: .bottom) {
            if viewModel.showUndo, let target = viewModel.undoTarget {
                UndoSnackBar(
                    beverageName: target.beverage?.localizedName ?? "",
                    secondsRemaining: viewModel.undoSecondsRemaining
                ) {
                    viewModel.undoLastRecord(context: modelContext)
                }
                .padding(.bottom, HitokuchiSpacing.m)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: viewModel.showUndo)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadData(context: modelContext)
        }
        .task {
            await viewModel.requestNotificationPermissionIfNeeded()
        }
        .onChange(of: modelContext.hasChanges) {
            viewModel.loadData(context: modelContext)
        }
        .onChange(of: viewModel.progress.isGoalAchieved) { wasAchieved, isAchieved in
            if !wasAchieved, isAchieved {
                showCelebration = true
            }
        }
    }
}
