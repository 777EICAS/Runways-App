//
//  AppTheme.swift
//  Runways App
//

import SwiftUI
import UIKit

enum AppTheme {
    // MARK: - Colors
    static let skyBlue = Color(red: 0.35, green: 0.65, blue: 0.95)
    static let skyBlueLight = Color(red: 0.55, green: 0.78, blue: 0.98)
    static let coral = Color(red: 0.98, green: 0.45, blue: 0.42)
    static let coralLight = Color(red: 1.0, green: 0.85, blue: 0.82)
    static let mint = Color(red: 0.35, green: 0.82, blue: 0.72)
    static let mintLight = Color(red: 0.85, green: 0.98, blue: 0.95)
    static let lavender = Color(red: 0.65, green: 0.55, blue: 0.92)
    static let lavenderLight = Color(red: 0.92, green: 0.88, blue: 1.0)
    static let warmOrange = Color(red: 1.0, green: 0.6, blue: 0.25)
    static let warmOrangeLight = Color(red: 1.0, green: 0.92, blue: 0.82)

    /// Vibrant blue for app title; adapts for dark mode (slightly brighter).
    static let headerBlue = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 1.0)
            : UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1.0)
    })
    /// Header gradient: darker muted blue at top.
    static let headerGradientTop = Color(red: 0.45, green: 0.68, blue: 0.9)
    /// Header gradient: lighter sky blue at bottom.
    static let headerGradientBottom = Color(red: 0.7, green: 0.85, blue: 0.98)
    /// Soft blue for full-page background (continues header theme).
    static let pageBackgroundBlue = Color(red: 0.82, green: 0.91, blue: 1.0)

    /// Primary text: dark on light mode, light on dark mode.
    static let textPrimary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 0.95, alpha: 1.0)
            : UIColor(white: 0.12, alpha: 1.0)
    })
    /// Secondary text: adapts for contrast.
    static let textSecondary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 0.72, alpha: 1.0)
            : UIColor(white: 0.35, alpha: 1.0)
    })
    /// Tertiary text: adapts for contrast.
    static let textTertiary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 0.58, alpha: 1.0)
            : UIColor(white: 0.5, alpha: 1.0)
    })

    /// Card/row fill: light in light mode, dark in dark mode (for list rows, pills).
    static let cardFill = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 0.22, alpha: 0.85)
            : UIColor.white.withAlphaComponent(0.55)
    })
    /// Card/row stroke: visible in both modes.
    static let cardStroke = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 0.4, alpha: 0.6)
            : UIColor.white.withAlphaComponent(0.35)
    })

    /// Unselected chip/filter background.
    static let chipFillUnselected = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(white: 0.28, alpha: 1.0)
            : UIColor(white: 0.92, alpha: 1.0)
    })

    /// Sky-to-sunset gradient (light blue at top → light orange at bottom).
    static let skyGradientTop = Color(red: 0.7, green: 0.85, blue: 0.98)
    static let skyGradientMiddle = Color(red: 0.9, green: 0.88, blue: 0.92)
    static let sunsetGradientBottom = Color(red: 1.0, green: 0.88, blue: 0.75)

    /// Dark mode page gradient (deep blue-grey to softer dark).
    static let darkGradientTop = Color(red: 0.12, green: 0.18, blue: 0.28)
    static let darkGradientMiddle = Color(red: 0.1, green: 0.14, blue: 0.2)
    static let darkGradientBottom = Color(red: 0.14, green: 0.12, blue: 0.18)

    // MARK: - Layout
    static let bubbleCorner: CGFloat = 20
    static let bubbleCornerSmall: CGFloat = 16
    static let cardPadding: CGFloat = 18
    static let sectionSpacing: CGFloat = 24
}

// MARK: - Bubbly card background
struct BubblyCardBackground: View {
    let color: Color
    let colorLight: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.bubbleCorner)
            .fill(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [
                            Color(white: 0.2),
                            Color(white: 0.16)
                        ]
                        : [
                            Color.white.opacity(0.95),
                            colorLight.opacity(0.85)
                        ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.bubbleCorner)
                    .stroke(color.opacity(colorScheme == .dark ? 0.5 : 0.35), lineWidth: 1)
            )
    }
}

// MARK: - App-wide sky-to-sunset background
struct SkySunsetBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    AppTheme.darkGradientTop,
                    AppTheme.darkGradientMiddle,
                    AppTheme.darkGradientBottom
                ]
                : [
                    AppTheme.skyGradientTop,
                    AppTheme.skyGradientMiddle,
                    AppTheme.sunsetGradientBottom
                ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Section header with coloured icon
struct BubblySectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(colorScheme == .dark ? 0.35 : 0.25))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}
