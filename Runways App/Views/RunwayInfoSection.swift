//
//  RunwayInfoSection.swift
//  Runways App
//

import SwiftUI

struct RunwayInfoSection: View {
    let airfield: Airfield
    @State private var isAirfieldInfoExpanded = false
    @State private var expandedRunwayIds: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
            airfieldInfoSection
            runwaysSection
        }
    }

    // MARK: - Airfield information (dropdown)
    private var airfieldInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isAirfieldInfoExpanded.toggle()
                }
            } label: {
                HStack {
                    BubblySectionHeader(title: "Airfield information", icon: "mappin.circle", color: AppTheme.mint)
                    Spacer()
                    Image(systemName: isAirfieldInfoExpanded ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.mint)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isAirfieldInfoExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    infoRow(label: "Elevation", value: "\(airfield.elevationMeters) m MSL")
                    if let iata = airfield.iataCode {
                        infoRow(label: "IATA", value: iata)
                    }
                    infoRow(label: "ICAO", value: airfield.icaoCode)
                }
                .padding(AppTheme.cardPadding)
                .background(BubblyCardBackground(color: AppTheme.mint, colorLight: AppTheme.mintLight))
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Runways (identifier visible, details in dropdown)
    private var runwaysSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "airplane.departure")
                    .font(.title2)
                    .foregroundStyle(AppTheme.mint)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.mint.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("Runways")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.bottom, 12)

            ForEach(airfield.runways) { runway in
                runwayRow(runway)
            }
        }
    }

    private func runwayRow(_ runway: Runway) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if expandedRunwayIds.contains(runway.id) {
                        expandedRunwayIds.remove(runway.id)
                    } else {
                        expandedRunwayIds.insert(runway.id)
                    }
                }
            } label: {
                HStack {
                    Text("Runway \(runway.designation)")
                        .font(.headline)
                        .foregroundStyle(AppTheme.mint)
                    Spacer()
                    Image(systemName: expandedRunwayIds.contains(runway.id) ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.mint)
                }
                .padding(AppTheme.cardPadding)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expandedRunwayIds.contains(runway.id) {
                VStack(alignment: .leading, spacing: 12) {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BubblyCardBackground(color: AppTheme.mint, colorLight: AppTheme.mintLight))
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 12)
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
}

#Preview {
    ScrollView {
        RunwayInfoSection(airfield: AirfieldData.lhr)
            .padding()
    }
}
