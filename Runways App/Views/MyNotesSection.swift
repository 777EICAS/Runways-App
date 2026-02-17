//
//  MyNotesSection.swift
//  Runways App
//

import SwiftUI

struct MyNotesSection: View {
    let airfieldId: String
    @Bindable var store: PrivateNotesStore
    @State private var isAdding = false
    @State private var newTitle = ""
    @State private var newBody = ""
    @State private var newCategory: NoteCategory = .general
    @State private var selectedCategory: NoteCategory? = nil
    @State private var editingNote: PrivateNote?
    @State private var editTitle = ""
    @State private var editBody = ""
    @State private var editCategory: NoteCategory = .general
    @FocusState private var isTitleFocused: Bool

    private var notes: [PrivateNote] {
        store.notes(for: airfieldId, category: selectedCategory)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BubblySectionHeader(title: "My notes", icon: "note.text", color: AppTheme.coral)
                Spacer()
                Button {
                    resetNewNote()
                    isAdding = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTitleFocused = true
                    }
                } label: {
                    Label("Add note", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.coral)
            }

            categoryFilter

            if notes.isEmpty && !isAdding {
                emptyState
            } else {
                ForEach(notes) { note in
                    noteCard(note)
                }
            }

            if isAdding {
                addNoteCard
            }
        }
        .sheet(item: $editingNote) { note in
            editNoteSheet(note: note)
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip("All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(NoteCategory.allCases, id: \.self) { category in
                    filterChip(category.displayName, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func filterChip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.coral : Color(white: 0.92))
                )
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        Text("No notes yet. Tap **Add note** to record your experience at this airfield.")
            .font(.subheadline)
            .foregroundStyle(AppTheme.textSecondary)
            .padding(.vertical, 20)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func noteCard(_ note: PrivateNote) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    if !note.body.isEmpty {
                        Text(note.body)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                categoryBadge(note.category)
            }
            HStack {
                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                HStack(spacing: 12) {
                    Button("Edit") {
                        editTitle = note.title
                        editBody = note.body
                        editCategory = note.category
                        editingNote = note
                    }
                    .buttonStyle(.borderless)
                    .tint(AppTheme.coral)
                    Button("Delete", role: .destructive) {
                        store.delete(note)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BubblyCardBackground(color: AppTheme.coral, colorLight: AppTheme.coralLight))
    }

    private func categoryBadge(_ category: NoteCategory) -> some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption2)
            Text(category.displayName)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(AppTheme.coral.opacity(0.25)))
    }

    private var addNoteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("Title", text: $newTitle)
                .textFieldStyle(.roundedBorder)
                .focused($isTitleFocused)
                .submitLabel(.next)
            TextField("Note…", text: $newBody, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)
            categoryPicker(selection: $newCategory)
            HStack {
                Button("Cancel") {
                    isTitleFocused = false
                    isAdding = false
                    resetNewNote()
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.coral)
                Button("Save") {
                    let t = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let b = newBody.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty || !b.isEmpty {
                        isTitleFocused = false
                        store.add(
                            airfieldId: airfieldId,
                            title: t.isEmpty ? "Note" : t,
                            body: b,
                            category: newCategory
                        )
                        resetNewNote()
                        isAdding = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.coral)
                .disabled(
                    newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                    newBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
        }
        .padding(AppTheme.cardPadding)
        .background(BubblyCardBackground(color: AppTheme.coral, colorLight: AppTheme.coralLight))
    }

    private func categoryPicker(selection: Binding<NoteCategory>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Category")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Picker("Category", selection: selection) {
                ForEach(NoteCategory.allCases, id: \.self) { category in
                    Label(category.displayName, systemImage: category.icon)
                        .tag(category)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private func editNoteSheet(note: PrivateNote) -> some View {
        NavigationStack {
            Form {
                TextField("Title", text: $editTitle)
                TextField("Note", text: $editBody, axis: .vertical)
                    .lineLimit(3...8)
                categoryPicker(selection: $editCategory)
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
                        let t = editTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        let b = editBody.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !t.isEmpty || !b.isEmpty {
                            store.update(note, title: t.isEmpty ? "Note" : t, body: b, category: editCategory)
                        }
                        editingNote = nil
                    }
                    .disabled(
                        editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                        editBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }

    private func resetNewNote() {
        newTitle = ""
        newBody = ""
        newCategory = .general
    }
}

#Preview {
    ScrollView {
        MyNotesSection(airfieldId: "EGLL", store: PrivateNotesStore())
            .padding()
    }
}
