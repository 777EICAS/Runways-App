//
//  RunwayInfoSection.swift
//  Runways App
//

import SwiftUI

struct RunwayInfoSection: View {
    let airfield: Airfield
    @State private var expandedRunwayIds: Set<String> = []

    var body: some View {
        runwaysSection
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
                    .foregroundStyle(AppTheme.textPrimary)
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
                HStack(spacing: 12) {
                    RunwayDirectionView(headingDegrees: runway.headingDegrees)
                    Text("Runway \(runway.designation)")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: expandedRunwayIds.contains(runway.id) ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
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
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text(relevantApproachTypes(for: runway).isEmpty ? "—" : relevantApproachTypes(for: runway).joined(separator: ", "))
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.textPrimary)
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

    /// Excludes VFR; shows only instrument approaches (ILS, RNP, RNAV, VOR, NDB, etc.).
    private func relevantApproachTypes(for runway: Runway) -> [String] {
        runway.approachTypes.filter { $0.uppercased() != "VFR" }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}

// MARK: - Runway direction indicator
/// Small depiction of a runway with centreline, oriented in the direction of the runway heading (aviation: 0° = North, 90° = East).
struct RunwayDirectionView: View {
    let headingDegrees: Int
    private let length: CGFloat = 30
    private let width: CGFloat = 7
    private static let runwayDark = Color(white: 0.22)
    private static let centrelineColor = Color.white.opacity(0.85)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width / 2)
                .fill(Self.runwayDark)
                .frame(width: length, height: width)
            // Centreline
            RoundedRectangle(cornerRadius: 1)
                .fill(Self.centrelineColor)
                .frame(width: length - 4, height: 1.5)
        }
        .rotationEffect(.degrees(Double(headingDegrees) - 90))
    }
}

#Preview {
    ScrollView {
        RunwayInfoSection(airfield: AirfieldData.lhr)
            .padding()
    }
}
