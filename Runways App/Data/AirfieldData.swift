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
                approachTypes: ["ILS", "RNP", "VOR", "NDB"]
            ),
            Runway(
                id: "EGLL-09R-27L",
                designation: "09R/27L",
                headingDegrees: 91,
                reciprocalHeadingDegrees: 271,
                lengthMeters: 3658,
                widthMeters: 50,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇬🇧",
        region: "Europe"
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
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "EGKK-08L-26R",
                designation: "08L/26R",
                headingDegrees: 76,
                reciprocalHeadingDegrees: 256,
                lengthMeters: 2561,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇬🇧",
        region: "Europe"
    )

    static let ewr: Airfield = Airfield(
        id: "KEWR",
        name: "Newark Liberty International",
        icaoCode: "KEWR",
        iataCode: "EWR",
        elevationMeters: 5,
        runways: [
            Runway(
                id: "KEWR-11-29",
                designation: "11/29",
                headingDegrees: 110,
                reciprocalHeadingDegrees: 290,
                lengthMeters: 2049,
                widthMeters: 46,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "KEWR-04L-22R",
                designation: "04L/22R",
                headingDegrees: 40,
                reciprocalHeadingDegrees: 220,
                lengthMeters: 3353,
                widthMeters: 46,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "KEWR-04R-22L",
                designation: "04R/22L",
                headingDegrees: 40,
                reciprocalHeadingDegrees: 220,
                lengthMeters: 3050,
                widthMeters: 46,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇺🇸",
        region: "North America"
    )

    static let eham: Airfield = Airfield(
        id: "EHAM",
        name: "Amsterdam Schiphol",
        icaoCode: "EHAM",
        iataCode: "AMS",
        elevationMeters: -3,
        runways: [
            Runway(
                id: "EHAM-04-22",
                designation: "04/22",
                headingDegrees: 40,
                reciprocalHeadingDegrees: 220,
                lengthMeters: 2019,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "EHAM-06-24",
                designation: "06/24",
                headingDegrees: 60,
                reciprocalHeadingDegrees: 240,
                lengthMeters: 3440,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "EHAM-09-27",
                designation: "09/27",
                headingDegrees: 90,
                reciprocalHeadingDegrees: 270,
                lengthMeters: 3452,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "EHAM-18C-36C",
                designation: "18C/36C",
                headingDegrees: 180,
                reciprocalHeadingDegrees: 360,
                lengthMeters: 3298,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "EHAM-18L-36R",
                designation: "18L/36R",
                headingDegrees: 180,
                reciprocalHeadingDegrees: 360,
                lengthMeters: 3400,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "EHAM-18R-36L",
                designation: "18R/36L",
                headingDegrees: 180,
                reciprocalHeadingDegrees: 360,
                lengthMeters: 3800,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR", "NDB"]
            )
        ],
        countryFlag: "🇳🇱",
        region: "Europe"
    )

    /// All airfields for v1.
    static var allAirfields: [Airfield] { [lhr, lgw, ewr, eham] }
}
