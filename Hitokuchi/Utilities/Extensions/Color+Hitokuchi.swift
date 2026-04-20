import SwiftUI

// MARK: - Theme Color System

extension Color {
    /// Hitokuchi design system colors
    enum hitokuchi {
        // MARK: - Background Colors
        static func bgPrimary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.bgPrimary
        }

        static func bgSecondary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.bgSecondary
        }

        static func bgTertiary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.bgTertiary
        }

        // MARK: - Text Colors
        static func textPrimary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.textPrimary
        }

        static func textSecondary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.textSecondary
        }

        static func textTertiary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.textTertiary
        }

        // MARK: - Accent Colors
        static func accentPrimary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.accentPrimary
        }

        static func accentSecondary(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.accentSecondary
        }

        static func accentSuccess(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            let colors = themeColors(theme, colorScheme)
            return colors.accentSuccess
        }

        static func accentWarning(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            themeColors(theme, colorScheme).accentWarning
        }

        static func accentError(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            themeColors(theme, colorScheme).accentError
        }

        // MARK: - Other Colors
        static func borderDefault(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            themeColors(theme, colorScheme).borderDefault
        }

        static func fillButton(for theme: AppTheme, colorScheme: ColorScheme) -> Color {
            themeColors(theme, colorScheme).accentPrimary
        }
    }
}

// MARK: - Theme Color Set

struct ThemeColorSet {
    let bgPrimary: Color
    let bgSecondary: Color
    let bgTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let accentPrimary: Color
    let accentSecondary: Color
    let accentSuccess: Color
    let accentWarning: Color
    let accentError: Color
    let borderDefault: Color
}

// MARK: - Theme Color Lookup

extension Color.hitokuchi {
    static func themeColors(_ theme: AppTheme, _ colorScheme: ColorScheme) -> ThemeColorSet {
        // Night theme ignores system colorScheme (always dark)
        let isDark = theme == .night ? true : colorScheme == .dark

        switch theme {
        case .default:  return isDark ? defaultDark : defaultLight
        case .houjicha: return isDark ? houjichaDark : houjichaLight
        case .sakura:   return isDark ? sakuraDark : sakuraLight
        case .ocean:    return isDark ? oceanDark : oceanLight
        case .forest:   return isDark ? forestDark : forestLight
        case .sunset:   return isDark ? sunsetDark : sunsetLight
        case .night:    return nightColors
        }
    }

    // MARK: - Default Theme (Water Blue)
    static let defaultLight = ThemeColorSet(
        bgPrimary:      Color(red: 244/255, green: 251/255, blue: 253/255),
        bgSecondary:    Color(red: 234/255, green: 245/255, blue: 250/255),
        bgTertiary:     Color(red: 216/255, green: 236/255, blue: 245/255),
        textPrimary:    Color(red: 30/255, green: 58/255, blue: 77/255),
        textSecondary:  Color(red: 91/255, green: 126/255, blue: 148/255),
        textTertiary:   Color(red: 143/255, green: 170/255, blue: 189/255),
        accentPrimary:  Color(red: 91/255, green: 173/255, blue: 214/255),
        accentSecondary: Color(red: 143/255, green: 207/255, blue: 232/255),
        accentSuccess:  Color(red: 107/255, green: 174/255, blue: 158/255),
        accentWarning:  Color(red: 212/255, green: 149/255, blue: 107/255),
        accentError:    Color(red: 199/255, green: 91/255, blue: 91/255),
        borderDefault:  Color(red: 204/255, green: 228/255, blue: 238/255)
    )

    static let defaultDark = ThemeColorSet(
        bgPrimary:      Color(red: 18/255, green: 28/255, blue: 36/255),
        bgSecondary:    Color(red: 29/255, green: 42/255, blue: 52/255),
        bgTertiary:     Color(red: 37/255, green: 53/255, blue: 66/255),
        textPrimary:    Color(red: 232/255, green: 244/255, blue: 252/255),
        textSecondary:  Color(red: 159/255, green: 190/255, blue: 209/255),
        textTertiary:   Color(red: 110/255, green: 143/255, blue: 163/255),
        accentPrimary:  Color(red: 112/255, green: 190/255, blue: 222/255),
        accentSecondary: Color(red: 159/255, green: 213/255, blue: 236/255),
        accentSuccess:  Color(red: 125/255, green: 186/255, blue: 171/255),
        accentWarning:  Color(red: 224/255, green: 168/255, blue: 125/255),
        accentError:    Color(red: 212/255, green: 112/255, blue: 112/255),
        borderDefault:  Color(red: 46/255, green: 64/255, blue: 80/255)
    )

    // MARK: - Houjicha Theme (Warm Brown — formerly Default, now paid)
    static let houjichaLight = ThemeColorSet(
        bgPrimary:      Color(red: 255/255, green: 251/255, blue: 245/255),
        bgSecondary:    Color(red: 255/255, green: 247/255, blue: 238/255),
        bgTertiary:     Color(red: 245/255, green: 237/255, blue: 227/255),
        textPrimary:    Color(red: 44/255, green: 37/255, blue: 32/255),
        textSecondary:  Color(red: 140/255, green: 126/255, blue: 115/255),
        textTertiary:   Color(red: 181/255, green: 169/255, blue: 157/255),
        accentPrimary:  Color(red: 200/255, green: 121/255, blue: 65/255),
        accentSecondary: Color(red: 212/255, green: 165/255, blue: 116/255),
        accentSuccess:  Color(red: 107/255, green: 155/255, blue: 107/255),
        accentWarning:  Color(red: 212/255, green: 149/255, blue: 107/255),
        accentError:    Color(red: 199/255, green: 91/255, blue: 91/255),
        borderDefault:  Color(red: 232/255, green: 222/255, blue: 212/255)
    )

    static let houjichaDark = ThemeColorSet(
        bgPrimary:      Color(red: 28/255, green: 24/255, blue: 22/255),
        bgSecondary:    Color(red: 42/255, green: 36/255, blue: 32/255),
        bgTertiary:     Color(red: 53/255, green: 46/255, blue: 40/255),
        textPrimary:    Color(red: 245/255, green: 237/255, blue: 227/255),
        textSecondary:  Color(red: 181/255, green: 169/255, blue: 157/255),
        textTertiary:   Color(red: 140/255, green: 126/255, blue: 115/255),
        accentPrimary:  Color(red: 212/255, green: 149/255, blue: 107/255),
        accentSecondary: Color(red: 224/255, green: 184/255, blue: 146/255),
        accentSuccess:  Color(red: 125/255, green: 184/255, blue: 125/255),
        accentWarning:  Color(red: 224/255, green: 168/255, blue: 125/255),
        accentError:    Color(red: 212/255, green: 112/255, blue: 112/255),
        borderDefault:  Color(red: 61/255, green: 53/255, blue: 48/255)
    )

    // MARK: - Sakura Theme
    static let sakuraLight = ThemeColorSet(
        bgPrimary:      Color(red: 255/255, green: 245/255, blue: 245/255),
        bgSecondary:    Color(red: 255/255, green: 237/255, blue: 237/255),
        bgTertiary:     Color(red: 255/255, green: 224/255, blue: 224/255),
        textPrimary:    Color(red: 74/255, green: 32/255, blue: 48/255),
        textSecondary:  Color(red: 140/255, green: 90/255, blue: 106/255),
        textTertiary:   Color(red: 181/255, green: 140/255, blue: 157/255),
        accentPrimary:  Color(red: 199/255, green: 91/255, blue: 122/255),
        accentSecondary: Color(red: 212/255, green: 137/255, blue: 154/255),
        accentSuccess:  Color(red: 122/255, green: 155/255, blue: 107/255),
        accentWarning:  Color(red: 212/255, green: 149/255, blue: 107/255),
        accentError:    Color(red: 199/255, green: 91/255, blue: 91/255),
        borderDefault:  Color(red: 240/255, green: 216/255, blue: 221/255)
    )

    static let sakuraDark = ThemeColorSet(
        bgPrimary:      Color(red: 30/255, green: 20/255, blue: 24/255),
        bgSecondary:    Color(red: 44/255, green: 30/255, blue: 36/255),
        bgTertiary:     Color(red: 58/255, green: 40/255, blue: 48/255),
        textPrimary:    Color(red: 245/255, green: 224/255, blue: 229/255),
        textSecondary:  Color(red: 192/255, green: 154/255, blue: 165/255),
        textTertiary:   Color(red: 140/255, green: 106/255, blue: 117/255),
        accentPrimary:  Color(red: 224/255, green: 122/255, blue: 149/255),
        accentSecondary: Color(red: 224/255, green: 160/255, blue: 176/255),
        accentSuccess:  Color(red: 140/255, green: 184/255, blue: 125/255),
        accentWarning:  Color(red: 224/255, green: 168/255, blue: 125/255),
        accentError:    Color(red: 212/255, green: 112/255, blue: 112/255),
        borderDefault:  Color(red: 72/255, green: 48/255, blue: 58/255)
    )

    // MARK: - Ocean Theme
    static let oceanLight = ThemeColorSet(
        bgPrimary:      Color(red: 245/255, green: 250/255, blue: 255/255),
        bgSecondary:    Color(red: 235/255, green: 244/255, blue: 255/255),
        bgTertiary:     Color(red: 220/255, green: 238/255, blue: 255/255),
        textPrimary:    Color(red: 26/255, green: 40/255, blue: 64/255),
        textSecondary:  Color(red: 90/255, green: 112/255, blue: 144/255),
        textTertiary:   Color(red: 130/255, green: 155/255, blue: 185/255),
        accentPrimary:  Color(red: 58/255, green: 123/255, blue: 189/255),
        accentSecondary: Color(red: 106/255, green: 159/255, blue: 212/255),
        accentSuccess:  Color(red: 91/255, green: 155/255, blue: 122/255),
        accentWarning:  Color(red: 212/255, green: 149/255, blue: 107/255),
        accentError:    Color(red: 199/255, green: 91/255, blue: 91/255),
        borderDefault:  Color(red: 208/255, green: 224/255, blue: 240/255)
    )

    static let oceanDark = ThemeColorSet(
        bgPrimary:      Color(red: 16/255, green: 24/255, blue: 32/255),
        bgSecondary:    Color(red: 24/255, green: 36/255, blue: 48/255),
        bgTertiary:     Color(red: 32/255, green: 48/255, blue: 64/255),
        textPrimary:    Color(red: 224/255, green: 238/255, blue: 248/255),
        textSecondary:  Color(red: 144/255, green: 176/255, blue: 208/255),
        textTertiary:   Color(red: 100/255, green: 130/255, blue: 165/255),
        accentPrimary:  Color(red: 90/255, green: 155/255, blue: 213/255),
        accentSecondary: Color(red: 130/255, green: 178/255, blue: 225/255),
        accentSuccess:  Color(red: 112/255, green: 184/255, blue: 144/255),
        accentWarning:  Color(red: 224/255, green: 168/255, blue: 125/255),
        accentError:    Color(red: 212/255, green: 112/255, blue: 112/255),
        borderDefault:  Color(red: 48/255, green: 64/255, blue: 80/255)
    )

    // MARK: - Forest Theme
    static let forestLight = ThemeColorSet(
        bgPrimary:      Color(red: 245/255, green: 255/255, blue: 245/255),
        bgSecondary:    Color(red: 236/255, green: 255/255, blue: 236/255),
        bgTertiary:     Color(red: 221/255, green: 250/255, blue: 221/255),
        textPrimary:    Color(red: 26/255, green: 48/255, blue: 32/255),
        textSecondary:  Color(red: 80/255, green: 112/255, blue: 80/255),
        textTertiary:   Color(red: 120/255, green: 155/255, blue: 120/255),
        accentPrimary:  Color(red: 74/255, green: 140/255, blue: 74/255),
        accentSecondary: Color(red: 122/255, green: 184/255, blue: 122/255),
        accentSuccess:  Color(red: 58/255, green: 140/255, blue: 106/255),
        accentWarning:  Color(red: 212/255, green: 149/255, blue: 107/255),
        accentError:    Color(red: 199/255, green: 91/255, blue: 91/255),
        borderDefault:  Color(red: 200/255, green: 232/255, blue: 200/255)
    )

    static let forestDark = ThemeColorSet(
        bgPrimary:      Color(red: 16/255, green: 26/255, blue: 16/255),
        bgSecondary:    Color(red: 24/255, green: 36/255, blue: 24/255),
        bgTertiary:     Color(red: 32/255, green: 48/255, blue: 32/255),
        textPrimary:    Color(red: 224/255, green: 245/255, blue: 224/255),
        textSecondary:  Color(red: 144/255, green: 192/255, blue: 144/255),
        textTertiary:   Color(red: 100/255, green: 145/255, blue: 100/255),
        accentPrimary:  Color(red: 96/255, green: 176/255, blue: 96/255),
        accentSecondary: Color(red: 140/255, green: 200/255, blue: 140/255),
        accentSuccess:  Color(red: 80/255, green: 176/255, blue: 128/255),
        accentWarning:  Color(red: 224/255, green: 168/255, blue: 125/255),
        accentError:    Color(red: 212/255, green: 112/255, blue: 112/255),
        borderDefault:  Color(red: 48/255, green: 72/255, blue: 48/255)
    )

    // MARK: - Sunset Theme
    static let sunsetLight = ThemeColorSet(
        bgPrimary:      Color(red: 255/255, green: 250/255, blue: 240/255),
        bgSecondary:    Color(red: 255/255, green: 243/255, blue: 224/255),
        bgTertiary:     Color(red: 255/255, green: 232/255, blue: 200/255),
        textPrimary:    Color(red: 58/255, green: 32/255, blue: 16/255),
        textSecondary:  Color(red: 140/255, green: 96/255, blue: 64/255),
        textTertiary:   Color(red: 181/255, green: 140/255, blue: 107/255),
        accentPrimary:  Color(red: 204/255, green: 106/255, blue: 42/255),
        accentSecondary: Color(red: 212/255, green: 144/255, blue: 96/255),
        accentSuccess:  Color(red: 107/255, green: 155/255, blue: 91/255),
        accentWarning:  Color(red: 212/255, green: 149/255, blue: 107/255),
        accentError:    Color(red: 199/255, green: 91/255, blue: 91/255),
        borderDefault:  Color(red: 232/255, green: 212/255, blue: 184/255)
    )

    static let sunsetDark = ThemeColorSet(
        bgPrimary:      Color(red: 26/255, green: 18/255, blue: 8/255),
        bgSecondary:    Color(red: 40/255, green: 26/255, blue: 16/255),
        bgTertiary:     Color(red: 54/255, green: 36/255, blue: 24/255),
        textPrimary:    Color(red: 245/255, green: 232/255, blue: 208/255),
        textSecondary:  Color(red: 192/255, green: 160/255, blue: 112/255),
        textTertiary:   Color(red: 140/255, green: 112/255, blue: 80/255),
        accentPrimary:  Color(red: 224/255, green: 128/255, blue: 64/255),
        accentSecondary: Color(red: 224/255, green: 168/255, blue: 112/255),
        accentSuccess:  Color(red: 128/255, green: 184/255, blue: 112/255),
        accentWarning:  Color(red: 224/255, green: 168/255, blue: 125/255),
        accentError:    Color(red: 212/255, green: 112/255, blue: 112/255),
        borderDefault:  Color(red: 72/255, green: 48/255, blue: 32/255)
    )

    // MARK: - Night Theme (always dark)
    static let nightColors = ThemeColorSet(
        bgPrimary:      Color(red: 22/255, green: 20/255, blue: 30/255),
        bgSecondary:    Color(red: 32/255, green: 30/255, blue: 42/255),
        bgTertiary:     Color(red: 42/255, green: 40/255, blue: 54/255),
        textPrimary:    Color(red: 248/255, green: 246/255, blue: 252/255),
        textSecondary:  Color(red: 200/255, green: 194/255, blue: 214/255),
        textTertiary:   Color(red: 148/255, green: 140/255, blue: 168/255),
        accentPrimary:  Color(red: 144/255, green: 144/255, blue: 208/255),
        accentSecondary: Color(red: 176/255, green: 176/255, blue: 224/255),
        accentSuccess:  Color(red: 112/255, green: 176/255, blue: 144/255),
        accentWarning:  Color(red: 208/255, green: 168/255, blue: 128/255),
        accentError:    Color(red: 200/255, green: 112/255, blue: 112/255),
        borderDefault:  Color(red: 58/255, green: 56/255, blue: 72/255)
    )
}
