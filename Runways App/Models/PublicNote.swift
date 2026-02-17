//
//  PublicNote.swift
//  Runways App
//

import Foundation

struct PublicNote: Identifiable, Codable {
    var id: UUID
    var airfieldId: String
    var content: String
    var category: NoteCategory
    var createdAt: Date
    var updatedAt: Date
    var thumbsUp: Int
    var thumbsDown: Int

    init(id: UUID = UUID(), airfieldId: String, content: String, category: NoteCategory = .general, createdAt: Date = Date(), updatedAt: Date = Date(), thumbsUp: Int = 0, thumbsDown: Int = 0) {
        self.id = id
        self.airfieldId = airfieldId
        self.content = content
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.thumbsUp = thumbsUp
        self.thumbsDown = thumbsDown
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        airfieldId = try c.decode(String.self, forKey: .airfieldId)
        content = try c.decode(String.self, forKey: .content)
        category = try c.decodeIfPresent(NoteCategory.self, forKey: .category) ?? .general
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
        thumbsUp = try c.decodeIfPresent(Int.self, forKey: .thumbsUp) ?? 0
        thumbsDown = try c.decodeIfPresent(Int.self, forKey: .thumbsDown) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(airfieldId, forKey: .airfieldId)
        try c.encode(content, forKey: .content)
        try c.encode(category, forKey: .category)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
        try c.encode(thumbsUp, forKey: .thumbsUp)
        try c.encode(thumbsDown, forKey: .thumbsDown)
    }

    private enum CodingKeys: String, CodingKey {
        case id, airfieldId, content, category, createdAt, updatedAt, thumbsUp, thumbsDown
    }
}

/// Tracks which way this device voted on a note (for v1: one vote per note per device).
struct PublicNoteVote: Codable {
    var noteId: UUID
    var vote: VoteType
    var updatedAt: Date

    enum VoteType: String, Codable {
        case up
        case down
    }
}
