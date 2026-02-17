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
