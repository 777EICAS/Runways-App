//
//  PublicBoardStore.swift
//  Runways App
//

import Foundation

@Observable
final class PublicBoardStore {
    private(set) var notes: [PublicNote] = []
    private var votes: [UUID: PublicNoteVote.VoteType] = [:]
    private let notesKey = "RunwaysApp.PublicNotes"
    private let votesKey = "RunwaysApp.PublicNoteVotes"
    private let fileManager = FileManager.default

    init() {
        load()
    }

    func notes(for airfieldId: String, category: NoteCategory? = nil) -> [PublicNote] {
        var result = notes.filter { $0.airfieldId == airfieldId }
        if let category {
            result = result.filter { $0.category == category }
        }
        return result.sorted { $0.createdAt > $1.createdAt }
    }

    func add(airfieldId: String, content: String, category: NoteCategory = .general) {
        let note = PublicNote(airfieldId: airfieldId, content: content, category: category)
        notes.append(note)
        save()
    }

    func vote(noteId: UUID, vote: PublicNoteVote.VoteType) {
        guard let index = notes.firstIndex(where: { $0.id == noteId }) else { return }
        let previousVote = votes[noteId]
        if previousVote == .up { notes[index].thumbsUp -= 1 }
        if previousVote == .down { notes[index].thumbsDown -= 1 }
        if vote == .up { notes[index].thumbsUp += 1 }
        if vote == .down { notes[index].thumbsDown += 1 }
        votes[noteId] = vote
        save()
    }

    func removeVote(noteId: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == noteId }),
              let previousVote = votes[noteId] else { return }
        if previousVote == .up { notes[index].thumbsUp -= 1 }
        if previousVote == .down { notes[index].thumbsDown -= 1 }
        votes.removeValue(forKey: noteId)
        save()
    }

    func currentVote(for noteId: UUID) -> PublicNoteVote.VoteType? {
        votes[noteId]
    }

    private var documentsURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private func load() {
        if let url = documentsURL?.appending(path: "public_notes.json"),
           fileManager.fileExists(atPath: url.path()) {
            do {
                let data = try Data(contentsOf: url)
                notes = try JSONDecoder().decode([PublicNote].self, from: data)
            } catch {
                notes = []
            }
        }
        if let url = documentsURL?.appending(path: "public_note_votes.json"),
           fileManager.fileExists(atPath: url.path()) {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([PublicNoteVote].self, from: data)
                votes = Dictionary(uniqueKeysWithValues: decoded.map { ($0.noteId, $0.vote) })
            } catch {
                votes = [:]
            }
        }
    }

    private func save() {
        guard let base = documentsURL else { return }
        do {
            try JSONEncoder().encode(notes).write(to: base.appending(path: "public_notes.json"))
            let voteList = votes.map { PublicNoteVote(noteId: $0.key, vote: $0.value, updatedAt: Date()) }
            try JSONEncoder().encode(voteList).write(to: base.appending(path: "public_note_votes.json"))
        } catch { }
    }
}
