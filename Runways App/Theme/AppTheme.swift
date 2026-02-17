//
//  AppTheme.swift
//  Runways App
//

import SwiftUI

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

    /// Vibrant blue for app title (Crew Rest–style header).
    static let headerBlue = Color(red: 0, green: 0.48, blue: 1.0)
    /// Header gradient: darker muted blue at top.
    static let headerGradientTop = Color(red: 0.45, green: 0.68, blue: 0.9)
    /// Header gradient: lighter sky blue at bottom.
    static let headerGradientBottom = Color(red: 0.7, green: 0.85, blue: 0.98)
    /// Soft blue for full-page background (continues header theme).
    static let pageBackgroundBlue = Color(red: 0.82, green: 0.91, blue: 1.0)

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

    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.bubbleCorner)
            .fill(
                LinearGradient(
                    colors: [colorLight.opacity(0.6), colorLight.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.bubbleCorner)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Section header with coloured icon
struct BubblySectionHeader: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}
