//
//  PrivateNotesStore.swift
//  Runways App
//

import Foundation
import UIKit

@Observable
final class PrivateNotesStore {
    private(set) var notes: [PrivateNote] = []
    private let storageKey = "RunwaysApp.PrivateNotes"
    private let fileManager = FileManager.default

    private var imageDirectory: URL? {
        guard let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let dir = base.appending(path: "private_notes_images", directoryHint: .isDirectory)
        if !fileManager.fileExists(atPath: dir.path()) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

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

    func add(airfieldId: String, title: String, body: String, category: NoteCategory = .general, imageData: Data? = nil) {
        var note = PrivateNote(airfieldId: airfieldId, title: title, body: body, category: category)
        if let data = imageData, let filename = saveImage(data, for: note.id) {
            note.imageFileName = filename
        }
        notes.append(note)
        save()
    }

    func update(_ note: PrivateNote, title: String, body: String, category: NoteCategory, imageData: Data? = nil) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].title = title
        notes[index].body = body
        notes[index].category = category
        notes[index].updatedAt = Date()
        if let data = imageData {
            deleteImageFile(notes[index].imageFileName)
            _ = saveImage(data, for: note.id)
            notes[index].imageFileName = "\(note.id.uuidString).jpg"
        }
        save()
    }

    /// Remove the attached image from a note (keeps title/body/category).
    func removeImage(from note: PrivateNote) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        deleteImageFile(note.imageFileName)
        notes[index].imageFileName = nil
        notes[index].updatedAt = Date()
        save()
    }

    func delete(_ note: PrivateNote) {
        deleteImageFile(note.imageFileName)
        notes.removeAll { $0.id == note.id }
        save()
    }

    /// Load image data for a note (if it has an attachment). Returns nil if no image or file missing.
    func imageData(for note: PrivateNote) -> Data? {
        guard let name = note.imageFileName, let dir = imageDirectory else { return nil }
        let url = dir.appending(path: name)
        return (try? Data(contentsOf: url))
    }

    private func saveImage(_ data: Data, for noteId: UUID) -> String? {
        guard let dir = imageDirectory else { return nil }
        let filename = "\(noteId.uuidString).jpg"
        let url = dir.appending(path: filename)
        let imageDataToSave: Data
        if let uiImage = UIImage(data: data), let jpeg = uiImage.jpegData(compressionQuality: 0.75) {
            imageDataToSave = jpeg
        } else {
            imageDataToSave = data
        }
        do {
            try imageDataToSave.write(to: url)
            return filename
        } catch {
            return nil
        }
    }

    private func deleteImageFile(_ filename: String?) {
        guard let name = filename, let dir = imageDirectory else { return }
        let url = dir.appending(path: name)
        try? fileManager.removeItem(at: url)
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
