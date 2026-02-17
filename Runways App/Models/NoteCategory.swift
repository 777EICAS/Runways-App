//
//  NoteCategory.swift
//  Runways App
//

import Foundation

enum NoteCategory: String, Codable, CaseIterable {
    case taxi
    case takeOff
    case approach
    case general

    var displayName: String {
        switch self {
        case .taxi: return "Taxi"
        case .takeOff: return "Take off"
        case .approach: return "Approach"
        case .general: return "General"
        }
    }

    var icon: String {
        switch self {
        case .taxi: return "car.fill"
        case .takeOff: return "airplane.departure"
        case .approach: return "airplane.arrival"
        case .general: return "note.text"
        }
    }
}
