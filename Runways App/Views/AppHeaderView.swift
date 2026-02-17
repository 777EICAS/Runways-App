//
//  AppHeaderView.swift
//  Runways App
//

import SwiftUI

/// App title header – sits on the gradient with no banner.
struct AppHeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(AppTheme.headerBlue)

            Text("Runways App")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.headerBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

#Preview {
    AppHeaderView()
}
