import SwiftUI

// MARK: - Theme Environment Key

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .default
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - Spacing Constants

enum HitokuchiSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius Constants

enum HitokuchiRadius {
    static let none: CGFloat = 0
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
}

// MARK: - Page Margin

enum HitokuchiLayout {
    static let pageMargin: CGFloat = 24
    static let minTouchTarget: CGFloat = 48
    static let quickRecordSize: CGFloat = 104
    static let quickRecordHeight: CGFloat = 100
    static let quickRecordGridHeight: CGFloat = 88
    static let maxFavoriteCount: Int = 9
    static let progressBarHeight: CGFloat = 8
}
