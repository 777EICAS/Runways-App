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
        .background(SkySunsetBackground())
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var airfieldHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppTheme.headerBlue)
                if let flag = airfield.countryFlag {
                    Text(flag)
                        .font(.system(size: 36))
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 16)
            HStack(alignment: .center, spacing: 20) {
                Text(airfield.name.uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 2) {
                    if let iata = airfield.iataCode {
                        Text(iata)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Text(airfield.icaoCode)
                        .font(.system(size: 16, weight: airfield.iataCode != nil ? .medium : .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
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
