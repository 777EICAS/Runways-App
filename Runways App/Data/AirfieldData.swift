//
//  AirfieldData.swift
//  Runways App
//

import Foundation

enum AirfieldData {
    static let lhr: Airfield = Airfield(
        id: "EGLL",
        name: "London Heathrow",
        icaoCode: "EGLL",
        iataCode: "LHR",
        elevationMeters: 25,
        runways: [
            Runway(
                id: "EGLL-09L-27R",
                designation: "09L/27R",
                headingDegrees: 91,
                reciprocalHeadingDegrees: 271,
                lengthMeters: 3901,
                widthMeters: 50,
                approachTypes: ["ILS", "VFR"]
            ),
            Runway(
                id: "EGLL-09R-27L",
                designation: "09R/27L",
                headingDegrees: 91,
                reciprocalHeadingDegrees: 271,
                lengthMeters: 3658,
                widthMeters: 50,
                approachTypes: ["ILS", "VFR"]
            )
        ],
        countryFlag: "🇬🇧"
    )

    static let lgw: Airfield = Airfield(
        id: "EGKK",
        name: "London Gatwick",
        icaoCode: "EGKK",
        iataCode: "LGW",
        elevationMeters: 62,
        runways: [
            Runway(
                id: "EGKK-08R-26L",
                designation: "08R/26L",
                headingDegrees: 76,
                reciprocalHeadingDegrees: 256,
                lengthMeters: 3317,
                widthMeters: 45,
                approachTypes: ["ILS", "VFR"]
            ),
            Runway(
                id: "EGKK-08L-26R",
                designation: "08L/26R",
                headingDegrees: 76,
                reciprocalHeadingDegrees: 256,
                lengthMeters: 2561,
                widthMeters: 45,
                approachTypes: ["ILS", "VFR"]
            )
        ],
        countryFlag: "🇬🇧"
    )

    /// All airfields for v1.
    static var allAirfields: [Airfield] { [lhr, lgw] }
}
