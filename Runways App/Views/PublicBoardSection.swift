//
//  PublicBoardSection.swift
//  Runways App
//

import SwiftUI

struct PublicBoardSection: View {
    let airfieldId: String
    @Bindable var store: PublicBoardStore
    let isOnline: Bool
    var onPostTapped: (() -> Void)? = nil
    @State private var isComposing = false
    @State private var newNoteText = ""
    @State private var selectedCategory: NoteCategory? = nil
    @State private var newNoteCategory: NoteCategory = .general
    @State private var noteToDelete: PublicNote?
    @FocusState private var isComposeFocused: Bool

    private var notes: [PublicNote] { store.notes(for: airfieldId, category: selectedCategory) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                BubblySectionHeader(title: "Pilot board", icon: "bubble.left.and.bubble.right", color: AppTheme.lavender)
                if !isOnline {
                    Text("Offline")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.chipFillUnselected))
                }
                Spacer()
                Button {
                    newNoteText = ""
                    newNoteCategory = .general
                    isComposing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isComposeFocused = true
                    }
                    onPostTapped?()
                } label: {
                    Label("Post", systemImage: "square.and.pencil")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.lavender)
                .disabled(!isOnline)
            }

            categoryTabs

            if !isOnline {
                Text("Public notes are cached. Posting and voting require an internet connection.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            if notes.isEmpty && !isComposing {
                Text("No pilot notes yet. When online, tap **Post** to share your experience.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(notes) { note in
                    publicNoteCard(note)
                }
            }

            if isComposing {
                composeCard
                    .id("pilotBoardComposeCard")
            }
        }
        .alert("Delete post?", isPresented: Binding(
            get: { noteToDelete != nil },
            set: { if !$0 { noteToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                noteToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    store.delete(noteId: note.id)
                }
                noteToDelete = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    /// Tabbed-style category selector mirroring My notes (All, Taxi, Take off, Approach, General).
    private var categoryTabs: some View {
        HStack(spacing: 0) {
            categoryTab(label: "All", isSelected: selectedCategory == nil) {
                selectedCategory = nil
            }
            ForEach(NoteCategory.allCases, id: \.self) { category in
                categoryTab(label: category.displayName, isSelected: selectedCategory == category) {
                    selectedCategory = category
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.cardStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func categoryTab(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.lavender : .clear)
                .foregroundStyle(isSelected ? Color.white : AppTheme.textSecondary)
        }
        .buttonStyle(.plain)
    }

    private func publicNoteCard(_ note: PublicNote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(note.content)
                    .font(.body)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                categoryBadge(note.category)
            }
            HStack {
                Text(note.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        thumbsButton(noteId: note.id, vote: .up, count: note.thumbsUp)
                        thumbsButton(noteId: note.id, vote: .down, count: note.thumbsDown)
                    }
                    .disabled(!isOnline)
                    if store.canDelete(noteId: note.id) {
                        Button {
                            noteToDelete = note
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BubblyCardBackground(color: AppTheme.lavender, colorLight: AppTheme.lavenderLight))
    }

    private func categoryBadge(_ category: NoteCategory) -> some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption2)
            Text(category.displayName)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(AppTheme.lavender)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(AppTheme.chipFillUnselected))
    }

    private func thumbsButton(noteId: UUID, vote: PublicNoteVote.VoteType, count: Int) -> some View {
        let isSelected = store.currentVote(for: noteId) == vote
        return Button {
            if isSelected {
                store.removeVote(noteId: noteId)
            } else {
                store.vote(noteId: noteId, vote: vote)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: vote == .up ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                    .foregroundStyle(isSelected ? AppTheme.lavender : AppTheme.textSecondary)
                Text("\(count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(isSelected ? AppTheme.lavender : AppTheme.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var composeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Share something useful for other pilots…", text: $newNoteText, axis: .vertical)
                .lineLimit(3...8)
                .textFieldStyle(.roundedBorder)
                .focused($isComposeFocused)
            HStack(spacing: 8) {
                Text("Category")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                Picker("Category", selection: $newNoteCategory) {
                    ForEach(NoteCategory.allCases, id: \.self) { category in
                        Label(category.displayName, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppTheme.lavender)
            }
            HStack {
                Button("Cancel") {
                    isComposing = false
                    newNoteText = ""
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.lavender)
                Button("Post") {
                    let trimmed = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.add(airfieldId: airfieldId, content: trimmed, category: newNoteCategory)
                        newNoteText = ""
                        isComposing = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.lavender)
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(BubblyCardBackground(color: AppTheme.lavender, colorLight: AppTheme.lavenderLight))
    }
}

#Preview {
    ScrollView {
        PublicBoardSection(airfieldId: "EGLL", store: PublicBoardStore(), isOnline: true)
            .padding()
    }
}
