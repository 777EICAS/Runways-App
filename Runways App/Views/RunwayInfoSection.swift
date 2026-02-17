//
//  RunwayInfoSection.swift
//  Runways App
//

import SwiftUI

struct RunwayInfoSection: View {
    let airfield: Airfield
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    BubblySectionHeader(title: "Runway information", icon: "airplane.departure", color: AppTheme.mint)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.mint)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        infoRow(label: "Elevation", value: "\(airfield.elevationMeters) m MSL")
                        if let iata = airfield.iataCode {
                            infoRow(label: "IATA", value: iata)
                        }
                        infoRow(label: "ICAO", value: airfield.icaoCode)
                    }
                    .padding(AppTheme.cardPadding)
                    .background(BubblyCardBackground(color: AppTheme.mint, colorLight: AppTheme.mintLight))

                    ForEach(airfield.runways) { runway in
                        runwayCard(runway)
                    }
                }
                .padding(.top, 12)
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.mint)
        }
    }

    private func runwayCard(_ runway: Runway) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Runway \(runway.designation)")
                .font(.headline)
                .foregroundStyle(AppTheme.mint)
            Divider()
                .background(AppTheme.mint.opacity(0.3))
            infoRow(label: "Heading", value: "\(runway.headingDegrees)° / \(runway.reciprocalHeadingDegrees)°")
            infoRow(label: "Length", value: "\(runway.lengthMeters) m")
            infoRow(label: "Width", value: "\(runway.widthMeters) m")
            HStack {
                Text("Approaches")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(runway.approachTypes.joined(separator: ", "))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.mint)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(BubblyCardBackground(color: AppTheme.mint, colorLight: AppTheme.mintLight))
    }
}

#Preview {
    ScrollView {
        RunwayInfoSection(airfield: AirfieldData.lhr)
            .padding()
    }
}
