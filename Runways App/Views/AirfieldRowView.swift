//
//  AirfieldRowView.swift
//  Runways App
//

import SwiftUI

struct AirfieldRowView: View {
    let airfield: Airfield

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.bubbleCornerSmall)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.skyBlueLight, AppTheme.skyBlue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Text(airfield.iataCode ?? String(airfield.icaoCode.prefix(3)))
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.skyBlue)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(airfield.name)
                    .font(.headline)
                Text(airfield.icaoCode)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.skyBlue.opacity(0.7))
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        AirfieldRowView(airfield: AirfieldData.lhr)
    }
}
