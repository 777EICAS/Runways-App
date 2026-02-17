//
//  PublicNote.swift
//  Runways App
//

import Foundation

struct PublicNote: Identifiable, Codable {
    var id: UUID
    var airfieldId: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var thumbsUp: Int
    var thumbsDown: Int

    init(id: UUID = UUID(), airfieldId: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date(), thumbsUp: Int = 0, thumbsDown: Int = 0) {
        self.id = id
        self.airfieldId = airfieldId
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.thumbsUp = thumbsUp
        self.thumbsDown = thumbsDown
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
