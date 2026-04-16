import SwiftUI
import SwiftData

struct HomeView: View {
    let storeManager: StoreManagerService

    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel = HomeViewModel()

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

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HitokuchiSpacing.s) {
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

                // Undo Snack Bar
                if viewModel.showUndo, let target = viewModel.undoTarget {
                    UndoSnackBar(
                        beverageName: target.beverage?.localizedName ?? "",
                        secondsRemaining: viewModel.undoSecondsRemaining
                    ) {
                        viewModel.undoLastRecord(context: modelContext)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: viewModel.showUndo)

                    Spacer().frame(height: HitokuchiSpacing.s)
                }

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
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadData(context: modelContext)
        }
        .onChange(of: modelContext.hasChanges) {
            viewModel.loadData(context: modelContext)
        }
    }
}
