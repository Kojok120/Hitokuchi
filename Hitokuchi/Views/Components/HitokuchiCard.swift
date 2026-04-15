import SwiftUI

struct HitokuchiCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("simpleLayoutMode") private var simpleLayoutMode = false

    var body: some View {
        VStack(alignment: .leading, spacing: HitokuchiSpacing.xs) {
            content()
        }
        .padding(HitokuchiSpacing.m)
        .background(Color.hitokuchi.bgSecondary(for: theme, colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: HitokuchiRadius.m))
        .overlay(
            simpleLayoutMode
                ? RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                    .stroke(Color.hitokuchi.borderDefault(for: theme, colorScheme: colorScheme), lineWidth: 1)
                : nil
        )
        .shadow(
            color: simpleLayoutMode
                ? .clear
                : Color.hitokuchi.textPrimary(for: theme, colorScheme: colorScheme).opacity(0.05),
            radius: 3, x: 0, y: 1
        )
    }
}

struct HitokuchiHighlightedCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: HitokuchiSpacing.xs) {
            content()
        }
        .padding(HitokuchiSpacing.m)
        .background(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme).opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HitokuchiRadius.m))
        .overlay(
            RoundedRectangle(cornerRadius: HitokuchiRadius.m)
                .stroke(Color.hitokuchi.accentPrimary(for: theme, colorScheme: colorScheme), lineWidth: 1)
        )
    }
}
