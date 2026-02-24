//
//  MyNotesSection.swift
//  Runways App
//

import SwiftUI
import PhotosUI
import UIKit

struct MyNotesSection: View {
    let airfieldId: String
    @Bindable var store: PrivateNotesStore
    @Bindable var publicBoardStore: PublicBoardStore
    let isOnline: Bool
    var onAddNoteTapped: (() -> Void)? = nil
    @State private var isAdding = false
    @State private var showSavedToBothOfflineMessage = false
    @State private var newTitle = ""
    @State private var newBody = ""
    @State private var newCategory: NoteCategory = .general
    @State private var newPhotoItem: PhotosPickerItem?
    @State private var newImageData: Data?
    @State private var selectedCategory: NoteCategory? = nil
    @State private var editingNote: PrivateNote?
    @State private var editTitle = ""
    @State private var editBody = ""
    @State private var editCategory: NoteCategory = .general
    @State private var editPhotoItem: PhotosPickerItem?
    @State private var editImageData: Data?
    @State private var editRemoveImage = false
    @State private var expandedNoteIds: Set<UUID> = []
    @State private var photoToView: UIImage?
    @FocusState private var isTitleFocused: Bool

    private var notes: [PrivateNote] {
        store.notes(for: airfieldId, category: selectedCategory)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                BubblySectionHeader(title: "My notes", icon: "note.text", color: AppTheme.coral)
                Spacer()
                Button {
                    resetNewNote()
                    isAdding = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTitleFocused = true
                    }
                    onAddNoteTapped?()
                } label: {
                    Label("Add note", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.coral)
            }

            categoryTabs

            if notes.isEmpty && !isAdding {
                emptyState
            } else {
                ForEach(notes) { note in
                    noteCard(note)
                }
            }

            if isAdding {
                addNoteCard
                    .id("addNoteCard")
            }
        }
        .sheet(item: $editingNote) { note in
            editNoteSheet(note: note)
        }
        .fullScreenCover(isPresented: Binding(
            get: { photoToView != nil },
            set: { if !$0 { photoToView = nil } }
        )) {
            if let image = photoToView {
                ZoomablePhotoView(image: image, photoToView: $photoToView)
            }
        }
        .alert("Saved to my notes", isPresented: $showSavedToBothOfflineMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Will post to pilot board when you're back online.")
        }
    }

    /// Tabbed-style category selector (All, Taxi, Take off, Approach, General).
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
                .background(isSelected ? AppTheme.coral : .clear)
                .foregroundStyle(isSelected ? Color.white : AppTheme.textSecondary)
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
        let isExpanded = expandedNoteIds.contains(note.id)
        return VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if expandedNoteIds.contains(note.id) {
                        _ = expandedNoteIds.remove(note.id)
                    } else {
                        expandedNoteIds.insert(note.id)
                    }
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(note.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                                .multilineTextAlignment(.leading)
                            if !note.body.isEmpty {
                                Text(note.body)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(isExpanded ? nil : 2)
                            }
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textTertiary)
                        categoryBadge(note.category)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                if let data = store.imageData(for: note), let uiImage = UIImage(data: data) {
                    Button {
                        photoToView = uiImage
                    } label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityHint("Tap to view full screen and zoom")
                }
            }

            HStack {
                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                Spacer()
                if isExpanded {
                    Button("Show less") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            _ = expandedNoteIds.remove(note.id)
                        }
                    }
                    .buttonStyle(.borderless)
                    .tint(AppTheme.coral)
                }
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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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
        VStack(alignment: .leading, spacing: 10) {
            TextField("Title", text: $newTitle)
                .textFieldStyle(.roundedBorder)
                .focused($isTitleFocused)
                .submitLabel(.next)
            TextField("Note…", text: $newBody, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)
            PhotosPicker(selection: $newPhotoItem, matching: .images) {
                Label(newImageData != nil ? "Photo attached" : "Add photo", systemImage: newImageData != nil ? "photo.fill" : "photo.badge.plus")
            }
            .onChange(of: newPhotoItem) { _, newItem in
                Task {
                    newImageData = try? await newItem?.loadTransferable(type: Data.self)
                }
            }
            if newImageData != nil, let data = newImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            categoryPicker(selection: $newCategory)
            HStack(spacing: 12) {
                Button("Cancel") {
                    isTitleFocused = false
                    isAdding = false
                    resetNewNote()
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.coral)
                Button("Save") {
                    saveNote(postToPilotBoard: false)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.coral)
                .disabled(
                    newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                    newBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
                Button("Save & post to pilot board") {
                    saveNote(postToPilotBoard: true)
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.coral)
                .disabled(
                    newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                    newBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(BubblyCardBackground(color: AppTheme.coral, colorLight: AppTheme.coralLight))
    }

    private func saveNote(postToPilotBoard: Bool) {
        let t = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = newBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty || !b.isEmpty else { return }
        isTitleFocused = false
        let title = t.isEmpty ? "Note" : t
        store.add(
            airfieldId: airfieldId,
            title: title,
            body: b,
            category: newCategory,
            imageData: newImageData
        )
        if postToPilotBoard {
            let pilotContent = b.isEmpty ? title : "\(title)\n\n\(b)"
            if isOnline {
                publicBoardStore.add(airfieldId: airfieldId, content: pilotContent, category: newCategory)
            } else {
                publicBoardStore.addPending(airfieldId: airfieldId, content: pilotContent, category: newCategory)
                showSavedToBothOfflineMessage = true
            }
        }
        resetNewNote()
        isAdding = false
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
        let hasExistingImage = note.imageFileName != nil
        return NavigationStack {
            Form {
                TextField("Title", text: $editTitle)
                TextField("Note", text: $editBody, axis: .vertical)
                    .lineLimit(3...8)
                Section("Photo") {
                    if hasExistingImage && !editRemoveImage, let data = store.imageData(for: note), let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    if editImageData != nil, let data = editImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    PhotosPicker(selection: $editPhotoItem, matching: .images) {
                        Label(
                            (hasExistingImage && !editRemoveImage) || editImageData != nil ? "Replace photo" : "Add photo",
                            systemImage: "photo.badge.plus"
                        )
                    }
                    .onChange(of: editPhotoItem) { _, newItem in
                        Task {
                            editImageData = try? await newItem?.loadTransferable(type: Data.self)
                        }
                    }
                    if hasExistingImage && !editRemoveImage {
                        Button("Remove photo", role: .destructive) {
                            editRemoveImage = true
                            editPhotoItem = nil
                            editImageData = nil
                        }
                    }
                }
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
                            if editRemoveImage {
                                store.removeImage(from: note)
                            }
                            store.update(
                                note,
                                title: t.isEmpty ? "Note" : t,
                                body: b,
                                category: editCategory,
                                imageData: editPhotoItem != nil ? editImageData : nil
                            )
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
        .onAppear {
            editRemoveImage = false
            editPhotoItem = nil
            editImageData = nil
        }
    }

    private func resetNewNote() {
        newTitle = ""
        newBody = ""
        newCategory = .general
        newPhotoItem = nil
        newImageData = nil
    }
}

// MARK: - Full-screen zoomable photo viewer (SwiftUI so image always displays)
private struct ZoomablePhotoView: View {
    let image: UIImage
    @Binding var photoToView: UIImage?
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale < 1 {
                                withAnimation { scale = 1; lastScale = 1; offset = .zero; lastOffset = .zero }
                            } else if scale > 4 {
                                withAnimation { scale = 4; lastScale = 4 }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if scale > 1 {
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Button {
                photoToView = nil
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
            .buttonStyle(.plain)
            .padding(24)
            .contentShape(Rectangle())
        }
        .onAppear {
            lastScale = 1
            lastOffset = .zero
        }
    }
}

#Preview {
    ScrollView {
        MyNotesSection(airfieldId: "EGLL", store: PrivateNotesStore(), publicBoardStore: PublicBoardStore(), isOnline: true)
            .padding()
    }
}
