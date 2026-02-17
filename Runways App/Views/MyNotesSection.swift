//
//  MyNotesSection.swift
//  Runways App
//

import SwiftUI

struct MyNotesSection: View {
    let airfieldId: String
    @Bindable var store: PrivateNotesStore
    @State private var isAdding = false
    @State private var newNoteText = ""
    @State private var editingNote: PrivateNote?
    @State private var editText = ""

    private var notes: [PrivateNote] { store.notes(for: airfieldId) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BubblySectionHeader(title: "My notes", icon: "note.text", color: AppTheme.coral)
                Spacer()
                Button {
                    newNoteText = ""
                    isAdding = true
                } label: {
                    Label("Add note", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.coral)
            }

            if notes.isEmpty && !isAdding {
                emptyState
            } else {
                ForEach(notes) { note in
                    myNoteCard(note)
                }
            }

            if isAdding {
                addNoteCard
            }
        }
        .sheet(item: $editingNote) { note in
            editNoteSheet(note: note, editText: $editText)
        }
    }

    private var emptyState: some View {
        Text("No notes yet. Tap **Add note** to record your experience at this airfield.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.vertical, 20)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func myNoteCard(_ note: PrivateNote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.content)
                .font(.body)
            Text(note.updatedAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button("Edit") {
                    editText = note.content
                    editingNote = note
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.coral)
                Button("Delete", role: .destructive) {
                    store.delete(note)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BubblyCardBackground(color: AppTheme.coral, colorLight: AppTheme.coralLight))
    }

    private var addNoteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("Your note…", text: $newNoteText, axis: .vertical)
                .lineLimit(3...8)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") {
                    isAdding = false
                    newNoteText = ""
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.coral)
                Button("Save") {
                    let trimmed = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.add(airfieldId: airfieldId, content: trimmed)
                        newNoteText = ""
                        isAdding = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.coral)
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(BubblyCardBackground(color: AppTheme.coral, colorLight: AppTheme.coralLight))
    }

    private func editNoteSheet(note: PrivateNote, editText: Binding<String>) -> some View {
        NavigationStack {
            Form {
                TextField("Note", text: editText, axis: .vertical)
                    .lineLimit(3...8)
            }
            .navigationTitle("Edit note")
            .navigationBarTitleDisplayMode(.inline)
            .tint(AppTheme.coral)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editingNote = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = editText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            store.update(note, content: trimmed)
                        }
                        editingNote = nil
                    }
                    .disabled(editText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        MyNotesSection(airfieldId: "EGLL", store: PrivateNotesStore())
            .padding()
    }
}
