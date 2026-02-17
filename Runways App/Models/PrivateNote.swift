//
//  PrivateNote.swift
//  Runways App
//

import Foundation

struct PrivateNote: Identifiable, Codable {
    var id: UUID
    var airfieldId: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), airfieldId: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.airfieldId = airfieldId
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
