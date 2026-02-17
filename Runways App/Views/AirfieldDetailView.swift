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

    private let contentSectionSpacing: CGFloat = 14
    private let contentPadding: CGFloat = 14

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    airfieldHeader
                    VStack(alignment: .leading, spacing: contentSectionSpacing) {
                        RunwayInfoSection(airfield: airfield)
                        MyNotesSection(airfieldId: airfield.id, store: privateNotesStore)
                        PublicBoardSection(airfieldId: airfield.id, store: publicBoardStore, isOnline: isOnline)
                    }
                    .padding(contentPadding)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .scrollIndicators(.visible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkySunsetBackground())
        .scrollContentBackground(.hidden)
        // Title is rendered in the header (bigger + codes beside it).
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Compact header: flag inline with title + pills, pulled up toward nav bar.
    private var airfieldHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                titleWithFlag
                codesInline
            }
            VStack(alignment: .leading, spacing: 6) {
                titleWithFlag
                codesInline
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var titleWithFlag: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let flag = airfield.countryFlag {
                Text(flag)
                    .font(.system(size: 24))
            }
            Text(airfield.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)
        }
    }

    private var codesInline: some View {
        HStack(spacing: 8) {
            if let iata = airfield.iataCode {
                codePill(label: "IATA", value: iata)
            }
            codePill(label: "ICAO", value: airfield.icaoCode)
            codePill(label: "Elev", value: "\(Int(round(Double(airfield.elevationMeters) * 3.28084))) ft")
        }
    }

    private func codePill(label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textTertiary)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
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
