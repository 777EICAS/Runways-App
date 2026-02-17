//
//  Airfield.swift
//  Runways App
//

import Foundation

struct Airfield: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var icaoCode: String
    var iataCode: String?
    var elevationMeters: Int
    var runways: [Runway]
    /// Country flag emoji (e.g. "🇬🇧" for United Kingdom).
    var countryFlag: String?
    /// Region for grouping (e.g. "Europe", "North America").
    var region: String?
    /// Operating hours (e.g. "24h", "06:00–22:00").
    var operatingHours: String?
    /// True if the airfield has night curfew / night flight restrictions; nil if unknown.
    var hasCurfew: Bool?
}

struct Runway: Identifiable, Codable, Hashable {
    let id: String
    var designation: String
    var headingDegrees: Int
    var reciprocalHeadingDegrees: Int
    var lengthMeters: Int
    var widthMeters: Int
    var approachTypes: [String]
}
