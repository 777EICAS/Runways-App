//
//  PublicBoardSection.swift
//  Runways App
//

import SwiftUI

struct PublicBoardSection: View {
    let airfieldId: String
    @Bindable var store: PublicBoardStore
    let isOnline: Bool
    @State private var isComposing = false
    @State private var newNoteText = ""

    private var notes: [PublicNote] { store.notes(for: airfieldId) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BubblySectionHeader(title: "Pilot board", icon: "bubble.left.and.bubble.right", color: AppTheme.lavender)
                if !isOnline {
                    Text("Offline")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.lavenderLight))
                }
                Spacer()
                Button {
                    newNoteText = ""
                    isComposing = true
                } label: {
                    Label("Post", systemImage: "square.and.pencil")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.lavender)
                .disabled(!isOnline)
            }

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
            }
        }
    }

    private func publicNoteCard(_ note: PublicNote) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(note.content)
                .font(.body)
                .foregroundStyle(AppTheme.textPrimary)
            HStack {
                Text(note.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                HStack(spacing: 16) {
                    thumbsButton(noteId: note.id, vote: .up, count: note.thumbsUp)
                    thumbsButton(noteId: note.id, vote: .down, count: note.thumbsDown)
                }
                .disabled(!isOnline)
            }
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BubblyCardBackground(color: AppTheme.lavender, colorLight: AppTheme.lavenderLight))
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
        VStack(alignment: .leading, spacing: 14) {
            TextField("Share something useful for other pilots…", text: $newNoteText, axis: .vertical)
                .lineLimit(3...8)
                .textFieldStyle(.roundedBorder)
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
                        store.add(airfieldId: airfieldId, content: trimmed)
                        newNoteText = ""
                        isComposing = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.lavender)
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(BubblyCardBackground(color: AppTheme.lavender, colorLight: AppTheme.lavenderLight))
    }
}

#Preview {
    ScrollView {
        PublicBoardSection(airfieldId: "EGLL", store: PublicBoardStore(), isOnline: true)
            .padding()
    }
}
