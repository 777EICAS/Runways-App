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

    func notes(for airfieldId: String) -> [PrivateNote] {
        notes.filter { $0.airfieldId == airfieldId }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func add(airfieldId: String, content: String) {
        let note = PrivateNote(airfieldId: airfieldId, content: content)
        notes.append(note)
        save()
    }

    func update(_ note: PrivateNote, content: String) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].content = content
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
