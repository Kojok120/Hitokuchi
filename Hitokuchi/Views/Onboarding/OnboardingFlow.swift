import SwiftUI

struct OnboardingFlow: View {
    let onComplete: () -> Void

    @State private var currentStep: OnboardingStep = .welcome

    enum OnboardingStep {
        case welcome
        case favoriteSelect
    }

    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case .welcome:
                    WelcomeView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .favoriteSelect
                        }
                    }
                case .favoriteSelect:
                    FavoriteSelectView(onComplete: onComplete)
                }
            }
        }
    }
}
