//
//  AirfieldDetailView.swift
//  Runways App
//

import SwiftUI

struct AirfieldDetailView: View {
    let airfield: Airfield
    let privateNotesStore: PrivateNotesStore
    let publicBoardStore: PublicBoardStore
    let isOnline: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                airfieldHeader
                VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                    RunwayInfoSection(airfield: airfield)
                    MyNotesSection(airfieldId: airfield.id, store: privateNotesStore)
                    PublicBoardSection(airfieldId: airfield.id, store: publicBoardStore, isOnline: isOnline)
                }
                .padding(AppTheme.cardPadding)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    AppTheme.headerGradientBottom,
                    AppTheme.pageBackgroundBlue,
                    AppTheme.skyBlueLight.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var airfieldHeader: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: AppTheme.headerBlue.opacity(0.5), radius: 1, x: 0, y: 1)
                if let flag = airfield.countryFlag {
                    Text(flag)
                        .font(.system(size: 36))
                }
            }
            Text(airfield.name.uppercased())
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.headerBlue)
                .multilineTextAlignment(.center)
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
    NavigationStack {
        AirfieldDetailView(
            airfield: AirfieldData.lhr,
            privateNotesStore: PrivateNotesStore(),
            publicBoardStore: PublicBoardStore(),
            isOnline: true
        )
    }
}
