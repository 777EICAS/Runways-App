//
//  PrivateNote.swift
//  Runways App
//

import Foundation

struct PrivateNote: Identifiable, Codable {
    var id: UUID
    var airfieldId: String
    var title: String
    var body: String
    var category: NoteCategory
    var createdAt: Date
    var updatedAt: Date

    /// For migration: old notes had `content` only. We derive title from first line and use General.
    enum CodingKeys: String, CodingKey {
        case id, airfieldId, title, body, category, createdAt, updatedAt
        case content // legacy
    }

    init(id: UUID = UUID(), airfieldId: String, title: String, body: String, category: NoteCategory = .general, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.airfieldId = airfieldId
        self.title = title
        self.body = body
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        airfieldId = try c.decode(String.self, forKey: .airfieldId)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)

        if let t = try c.decodeIfPresent(String.self, forKey: .title),
           let b = try c.decodeIfPresent(String.self, forKey: .body) {
            title = t
            body = b
            if let raw = try c.decodeIfPresent(String.self, forKey: .category) {
                category = Self.migrateCategory(raw)
            } else {
                category = .general
            }
        } else if let content = try c.decodeIfPresent(String.self, forKey: .content) {
            let firstLine = content.split(separator: "\n").first.map(String.init) ?? content
            title = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
            body = content
            category = .general
        } else {
            title = "Note"
            body = ""
            category = .general
        }
    }

    private static func migrateCategory(_ raw: String) -> NoteCategory {
        switch raw {
        case "ground": return .taxi
        case "parking": return .general
        default: return NoteCategory(rawValue: raw) ?? .general
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(airfieldId, forKey: .airfieldId)
        try c.encode(title, forKey: .title)
        try c.encode(body, forKey: .body)
        try c.encode(category, forKey: .category)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
    }
}
