//
//  AppHeaderView.swift
//  Runways App
//

import SwiftUI

/// App title header – sits on the gradient with no banner. Optional cog opens settings.
struct AppHeaderView: View {
    var onSettingsTap: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(AppTheme.headerBlue)

                Text("Runways App")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.headerBlue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)

            if let onSettingsTap {
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundStyle(AppTheme.headerBlue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
}

#Preview {
    AppHeaderView(onSettingsTap: {})
}
