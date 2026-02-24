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
        region: "Europe",
        operatingHours: "24h",
        hasCurfew: true,
        searchableLocation: "London United Kingdom England"
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
        region: "Europe",
        operatingHours: "24h",
        hasCurfew: true,
        searchableLocation: "London United Kingdom England"
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
        region: "North America",
        operatingHours: "24h",
        hasCurfew: false,
        searchableLocation: "Newark United States America New Jersey"
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
        region: "Europe",
        operatingHours: "24h",
        hasCurfew: true,
        searchableLocation: "Amsterdam Netherlands"
    )

    static let lfsb: Airfield = Airfield(
        id: "LFSB",
        name: "EuroAirport Basel Mulhouse Freiburg",
        icaoCode: "LFSB",
        iataCode: "BSL",
        elevationMeters: 270,
        runways: [
            Runway(
                id: "LFSB-08-26",
                designation: "08/26",
                headingDegrees: 80,
                reciprocalHeadingDegrees: 260,
                lengthMeters: 1715,
                widthMeters: 60,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "LFSB-15-33",
                designation: "15/33",
                headingDegrees: 150,
                reciprocalHeadingDegrees: 330,
                lengthMeters: 3900,
                widthMeters: 60,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇫🇷",
        region: "Europe",
        operatingHours: "24h",
        hasCurfew: true,
        searchableLocation: "Basel Mulhouse Freiburg France Switzerland"
    )

    static let egjj: Airfield = Airfield(
        id: "EGJJ",
        name: "Jersey",
        icaoCode: "EGJJ",
        iataCode: "JER",
        elevationMeters: 84,
        runways: [
            Runway(
                id: "EGJJ-08-26",
                designation: "08/26",
                headingDegrees: 80,
                reciprocalHeadingDegrees: 260,
                lengthMeters: 1706,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇬🇧",
        region: "Europe",
        operatingHours: "07:00–21:00",
        hasCurfew: true,
        searchableLocation: "Jersey United Kingdom Channel Islands"
    )

    static let egph: Airfield = Airfield(
        id: "EGPH",
        name: "Edinburgh",
        icaoCode: "EGPH",
        iataCode: "EDI",
        elevationMeters: 41,
        runways: [
            Runway(
                id: "EGPH-06-24",
                designation: "06/24",
                headingDegrees: 60,
                reciprocalHeadingDegrees: 240,
                lengthMeters: 2551,
                widthMeters: 46,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇬🇧",
        region: "Europe",
        operatingHours: "24h",
        hasCurfew: true,
        searchableLocation: "Edinburgh Scotland United Kingdom"
    )

    static let liml: Airfield = Airfield(
        id: "LIML",
        name: "Milan Linate",
        icaoCode: "LIML",
        iataCode: "LIN",
        elevationMeters: 108,
        runways: [
            Runway(
                id: "LIML-18-36",
                designation: "18/36",
                headingDegrees: 180,
                reciprocalHeadingDegrees: 360,
                lengthMeters: 2441,
                widthMeters: 60,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇮🇹",
        region: "Europe",
        operatingHours: "24h",
        hasCurfew: true,
        searchableLocation: "Milan Italy Linate"
    )

    static let lsgg: Airfield = Airfield(
        id: "LSGG",
        name: "Geneva",
        icaoCode: "LSGG",
        iataCode: "GVA",
        elevationMeters: 430,
        runways: [
            Runway(
                id: "LSGG-04-22",
                designation: "04/22",
                headingDegrees: 40,
                reciprocalHeadingDegrees: 220,
                lengthMeters: 3903,
                widthMeters: 50,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇨🇭",
        region: "Europe",
        operatingHours: "24h",
        hasCurfew: true,
        searchableLocation: "Geneva Switzerland"
    )

    static let fimp: Airfield = Airfield(
        id: "FIMP",
        name: "Sir Seewoosagur Ramgoolam International",
        icaoCode: "FIMP",
        iataCode: "MRU",
        elevationMeters: 56,
        runways: [
            Runway(
                id: "FIMP-14-32",
                designation: "14/32",
                headingDegrees: 117,
                reciprocalHeadingDegrees: 297,
                lengthMeters: 3370,
                widthMeters: 45,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇲🇺",
        region: "Africa",
        operatingHours: "24h",
        hasCurfew: false,
        searchableLocation: "Mauritius Plaisance Curepipe"
    )

    static let wsss: Airfield = Airfield(
        id: "WSSS",
        name: "Singapore Changi",
        icaoCode: "WSSS",
        iataCode: "SIN",
        elevationMeters: 7,
        runways: [
            Runway(
                id: "WSSS-02L-20R",
                designation: "02L/20R",
                headingDegrees: 20,
                reciprocalHeadingDegrees: 200,
                lengthMeters: 4000,
                widthMeters: 60,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "WSSS-02C-20C",
                designation: "02C/20C",
                headingDegrees: 20,
                reciprocalHeadingDegrees: 200,
                lengthMeters: 4000,
                widthMeters: 60,
                approachTypes: ["ILS", "RNP", "VOR"]
            ),
            Runway(
                id: "WSSS-02R-20L",
                designation: "02R/20L",
                headingDegrees: 20,
                reciprocalHeadingDegrees: 200,
                lengthMeters: 2750,
                widthMeters: 60,
                approachTypes: ["ILS", "RNP", "VOR"]
            )
        ],
        countryFlag: "🇸🇬",
        region: "Asia",
        operatingHours: "24h",
        hasCurfew: false,
        searchableLocation: "Singapore"
    )

    /// All airfields for v1.
    static var allAirfields: [Airfield] { [lhr, lgw, ewr, eham, lfsb, egjj, egph, liml, lsgg, fimp, wsss] }
}
