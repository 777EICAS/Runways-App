//
//  AppHeaderView.swift
//  Runways App
//

import SwiftUI

/// App title header styled with gradient background and centered icon, similar to Crew Rest Calculator.
struct AppHeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.white)
                .shadow(color: AppTheme.headerBlue.opacity(0.5), radius: 1, x: 0, y: 1)

            Text("Runways App")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.headerBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.headerGradientTop,
                    AppTheme.headerGradientBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    AppHeaderView()
}
