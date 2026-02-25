//
//  PublicBoardStore.swift
//  Runways App
//

import Auth
import Foundation

/// A post queued to be added to the community board when back online.
struct PendingPublicPost: Codable {
    var airfieldId: String
    var content: String
    var category: NoteCategory
    var createdAt: Date
}

@Observable
final class PublicBoardStore {
    private(set) var notes: [PublicNote] = []
    private var votes: [UUID: PublicNoteVote.VoteType] = [:]
    private(set) var pendingPosts: [PendingPublicPost] = []
    private var myPostIds: Set<UUID> = []
    private let notesKey = "RunwaysApp.PublicNotes"
    private let votesKey = "RunwaysApp.PublicNoteVotes"
    private let pendingKey = "RunwaysApp.PendingPublicPosts"
    private let myPostIdsKey = "RunwaysApp.MyPublicNoteIds"
    private let fileManager = FileManager.default

    /// When set and signed in, forum uses Supabase. Injected from view layer.
    var authService: AuthService?

    private let forumService = ForumService()

    init() {
        load()
    }

    var useSupabase: Bool {
        guard SupabaseConfig.isConfigured, let auth = authService, auth.isSignedIn else { return false }
        return true
    }

    func notes(for airfieldId: String, category: NoteCategory? = nil) -> [PublicNote] {
        var result = notes.filter { $0.airfieldId == airfieldId }
        if let category {
            result = result.filter { $0.category == category }
        }
        return result.sorted { $0.createdAt > $1.createdAt }
    }

    /// Fetch from Supabase when signed in and configured. Call when showing community board for an airfield.
    func fetchFromSupabaseIfNeeded(airfieldId: String) async {
        guard useSupabase, let userId = authService?.currentUser?.id else { return }
        let fetched = await forumService.fetchPosts(airfieldId: airfieldId)
        let postIds = fetched.map(\.id)
        let myVotes = await forumService.fetchMyVotes(postIds: postIds, userId: userId)
        await MainActor.run {
            notes = notes.filter { $0.airfieldId != airfieldId } + fetched
            for (id, vote) in myVotes {
                votes[id] = vote
            }
        }
    }

    /// Add a post. When authorId and authorDisplayName are provided and useSupabase, posts to Supabase.
    func add(airfieldId: String, content: String, category: NoteCategory = .general, authorId: UUID? = nil, authorDisplayName: String? = nil) {
        if useSupabase, let authorId = authorId {
            let name = authorDisplayName ?? ""
            Task {
                if let note = await forumService.addPost(airfieldId: airfieldId, authorId: authorId, authorDisplayName: name, content: content, category: category) {
                    await MainActor.run {
                        notes.append(note)
                    }
                }
            }
            return
        }
        let note = PublicNote(airfieldId: airfieldId, content: content, category: category)
        notes.append(note)
        myPostIds.insert(note.id)
        save()
        saveMyPostIds()
    }

    /// Queue a post for the community board when offline. Call `processPendingPosts()` when back online.
    func addPending(airfieldId: String, content: String, category: NoteCategory = .general) {
        let pending = PendingPublicPost(airfieldId: airfieldId, content: content, category: category, createdAt: Date())
        pendingPosts.append(pending)
        savePending()
    }

    /// Process all pending posts. When authorId and authorDisplayName are provided and useSupabase, posts to Supabase; otherwise adds locally.
    func processPendingPosts(authorId: UUID? = nil, authorDisplayName: String? = nil) {
        guard !pendingPosts.isEmpty else { return }
        let toProcess = pendingPosts
        pendingPosts.removeAll()
        savePending()
        for pending in toProcess {
            add(airfieldId: pending.airfieldId, content: pending.content, category: pending.category, authorId: authorId ?? authService?.currentUser?.id, authorDisplayName: authorDisplayName)
        }
    }

    private func savePending() {
        guard let base = documentsURL else { return }
        do {
            try JSONEncoder().encode(pendingPosts).write(to: base.appending(path: "pending_public_posts.json"))
        } catch { }
    }

    func vote(noteId: UUID, vote: PublicNoteVote.VoteType) {
        guard let index = notes.firstIndex(where: { $0.id == noteId }) else { return }
        if useSupabase, let userId = authService?.currentUser?.id {
            Task {
                let previousVote = await MainActor.run(body: { votes[noteId] })
                if previousVote == vote {
                    await forumService.removeVote(postId: noteId, userId: userId)
                    await MainActor.run {
                        if vote == .up { notes[index].thumbsUp -= 1 } else { notes[index].thumbsDown -= 1 }
                        votes.removeValue(forKey: noteId)
                    }
                } else {
                    await forumService.upsertVote(postId: noteId, userId: userId, vote: vote)
                    await MainActor.run {
                        if previousVote == .up { notes[index].thumbsUp -= 1 } else if previousVote == .down { notes[index].thumbsDown -= 1 }
                        if vote == .up { notes[index].thumbsUp += 1 } else { notes[index].thumbsDown += 1 }
                        votes[noteId] = vote
                    }
                }
            }
            return
        }
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
        if useSupabase, let userId = authService?.currentUser?.id {
            Task {
                await forumService.removeVote(postId: noteId, userId: userId)
                await MainActor.run {
                    if previousVote == .up { notes[index].thumbsUp -= 1 }
                    if previousVote == .down { notes[index].thumbsDown -= 1 }
                    votes.removeValue(forKey: noteId)
                }
            }
            return
        }
        if previousVote == .up { notes[index].thumbsUp -= 1 }
        if previousVote == .down { notes[index].thumbsDown -= 1 }
        votes.removeValue(forKey: noteId)
        save()
    }

    func currentVote(for noteId: UUID) -> PublicNoteVote.VoteType? {
        votes[noteId]
    }

    /// Whether the current user (this device) is allowed to delete this note (they created it).
    func canDelete(noteId: UUID) -> Bool {
        if useSupabase, let note = notes.first(where: { $0.id == noteId }), let currentId = authService?.currentUser?.id {
            return note.authorId == currentId
        }
        return myPostIds.contains(noteId)
    }

    /// Delete a note. Only succeeds if `canDelete(noteId)` is true.
    func delete(noteId: UUID) {
        if useSupabase, canDelete(noteId: noteId) {
            Task {
                await forumService.deletePost(postId: noteId)
                await MainActor.run {
                    notes.removeAll { $0.id == noteId }
                    votes.removeValue(forKey: noteId)
                }
            }
            return
        }
        guard myPostIds.contains(noteId) else { return }
        notes.removeAll { $0.id == noteId }
        votes.removeValue(forKey: noteId)
        myPostIds.remove(noteId)
        save()
        saveMyPostIds()
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
        if let url = documentsURL?.appending(path: "pending_public_posts.json"),
           fileManager.fileExists(atPath: url.path()) {
            do {
                let data = try Data(contentsOf: url)
                pendingPosts = try JSONDecoder().decode([PendingPublicPost].self, from: data)
            } catch {
                pendingPosts = []
            }
        }
        if let url = documentsURL?.appending(path: "my_public_note_ids.json"),
           fileManager.fileExists(atPath: url.path()) {
            do {
                let data = try Data(contentsOf: url)
                let uuids = try JSONDecoder().decode([UUID].self, from: data)
                myPostIds = Set(uuids)
            } catch {
                myPostIds = []
            }
        }
    }

    private func saveMyPostIds() {
        guard let base = documentsURL else { return }
        do {
            try JSONEncoder().encode(Array(myPostIds)).write(to: base.appending(path: "my_public_note_ids.json"))
        } catch { }
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
