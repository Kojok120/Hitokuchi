import SwiftUI

/// Confetti overlay for goal achievement celebration
struct CelebrationEffect: View {
    let isActive: Bool
    let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            if showConfetti, !reduceMotion {
                ForEach(0..<20, id: \.self) { index in
                    ConfettiPiece(
                        index: index,
                        baseColor: color
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onChange(of: isActive) { _, active in
            guard active else { return }
            showConfetti = true
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2.5))
                showConfetti = false
            }
        }
    }
}

/// A single confetti piece that animates from top to bottom
private struct ConfettiPiece: View {
    let index: Int
    let baseColor: Color

    @State private var isAnimating = false
    @State private var xOffset: CGFloat = 0
    @State private var fallDistance: CGFloat = 0
    @State private var size: CGFloat = 0
    @State private var duration: Double = 0
    @State private var rotation: Double = 0

    private var pieceColor: Color {
        let colors: [Color] = [baseColor, .yellow, .orange, baseColor.opacity(0.6), .white]
        return colors[index % colors.count]
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(pieceColor)
            .frame(width: size, height: size * 0.5)
            .rotationEffect(.degrees(isAnimating ? rotation : 0))
            .offset(
                x: xOffset,
                y: isAnimating ? fallDistance : -20
            )
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                xOffset = CGFloat(index % 5) * 70 - 140 + CGFloat.random(in: -20...20)
                fallDistance = CGFloat.random(in: 300...500)
                size = CGFloat.random(in: 5...9)
                duration = Double.random(in: 1.4...2.2)
                rotation = Double.random(in: 180...540)

                withAnimation(
                    .easeOut(duration: duration)
                    .delay(Double(index) * 0.03)
                ) {
                    isAnimating = true
                }
            }
    }
}
