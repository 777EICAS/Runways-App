//
//  PrivateNotesStore.swift
//  Runways App
//

import Foundation

@Observable
final class PrivateNotesStore {
    private(set) var notes: [PrivateNote] = []
    private let storageKey = "RunwaysApp.PrivateNotes"
    private let fileManager = FileManager.default

    init() {
        load()
    }

    func notes(for airfieldId: String, category: NoteCategory? = nil) -> [PrivateNote] {
        var result = notes.filter { $0.airfieldId == airfieldId }
        if let category {
            result = result.filter { $0.category == category }
        }
        return result.sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Airfield IDs that have at least one note (for "My notes" list filter).
    func airfieldIdsWithNotes() -> Set<String> {
        Set(notes.map(\.airfieldId))
    }

    func add(airfieldId: String, title: String, body: String, category: NoteCategory = .general) {
        let note = PrivateNote(airfieldId: airfieldId, title: title, body: body, category: category)
        notes.append(note)
        save()
    }

    func update(_ note: PrivateNote, title: String, body: String, category: NoteCategory) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].title = title
        notes[index].body = body
        notes[index].category = category
        notes[index].updatedAt = Date()
        save()
    }

    func delete(_ note: PrivateNote) {
        notes.removeAll { $0.id == note.id }
        save()
    }

    private var fileURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appending(path: "private_notes.json")
    }

    private func load() {
        guard let url = fileURL, fileManager.fileExists(atPath: url.path()) else { return }
        do {
            let data = try Data(contentsOf: url)
            notes = try JSONDecoder().decode([PrivateNote].self, from: data)
        } catch {
            notes = []
        }
    }

    private func save() {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: url)
        } catch { }
    }
}
