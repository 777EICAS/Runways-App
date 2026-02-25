//
//  ForumService.swift
//  Runways App
//

import Foundation
import Supabase

/// Supabase API for forum_posts and forum_votes.
struct ForumService {
    private let client = SupabaseClient.shared

    /// Row from forum_posts (snake_case from DB).
    struct ForumPostRow: Decodable {
        let id: UUID
        let airfieldId: String
        let authorId: UUID
        let authorDisplayName: String?
        let content: String
        let category: String
        let thumbsUp: Int
        let thumbsDown: Int
        let createdAt: Date
        let updatedAt: Date
        enum CodingKeys: String, CodingKey {
            case id
            case airfieldId = "airfield_id"
            case authorId = "author_id"
            case authorDisplayName = "author_display_name"
            case content
            case category
            case thumbsUp = "thumbs_up"
            case thumbsDown = "thumbs_down"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }

    func fetchPosts(airfieldId: String) async -> [PublicNote] {
        do {
            let rows: [ForumPostRow] = try await client
                .from("forum_posts")
                .select()
                .eq("airfield_id", value: airfieldId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return rows.map { row in
                PublicNote(
                    id: row.id,
                    airfieldId: row.airfieldId,
                    authorId: row.authorId,
                    authorDisplayName: row.authorDisplayName ?? "",
                    content: row.content,
                    category: NoteCategory(rawValue: row.category) ?? .general,
                    createdAt: row.createdAt,
                    updatedAt: row.updatedAt,
                    thumbsUp: row.thumbsUp,
                    thumbsDown: row.thumbsDown
                )
            }
        } catch {
            return []
        }
    }

    func addPost(airfieldId: String, authorId: UUID, authorDisplayName: String, content: String, category: NoteCategory) async -> PublicNote? {
        do {
            let payload = ForumPostInsert(
                airfieldId: airfieldId,
                authorId: authorId,
                authorDisplayName: authorDisplayName,
                content: content,
                category: category.rawValue
            )
            let rows: [ForumPostRow] = try await client
                .from("forum_posts")
                .insert(payload)
                .select()
                .execute()
                .value
            guard let row = rows.first else { return nil }
            return PublicNote(
                id: row.id,
                airfieldId: row.airfieldId,
                authorId: row.authorId,
                authorDisplayName: row.authorDisplayName ?? "",
                content: row.content,
                category: NoteCategory(rawValue: row.category) ?? .general,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
                thumbsUp: row.thumbsUp,
                thumbsDown: row.thumbsDown
            )
        } catch {
            return nil
        }
    }

    func fetchMyVotes(postIds: [UUID], userId: UUID) async -> [UUID: PublicNoteVote.VoteType] {
        guard !postIds.isEmpty else { return [:] }
        do {
            let rows: [ForumVoteRow] = try await client
                .from("forum_votes")
                .select()
                .eq("user_id", value: userId)
                .in("post_id", values: postIds)
                .execute()
                .value
            return Dictionary(uniqueKeysWithValues: rows.map { ($0.postId, $0.voteType) })
        } catch {
            return [:]
        }
    }

    func upsertVote(postId: UUID, userId: UUID, vote: PublicNoteVote.VoteType) async {
        do {
            let payload = ForumVoteUpsert(postId: postId, userId: userId, vote: vote.rawValue)
            try await client
                .from("forum_votes")
                .upsert(payload)
                .execute()
        } catch { }
    }

    func removeVote(postId: UUID, userId: UUID) async {
        do {
            try await client
                .from("forum_votes")
                .delete()
                .eq("post_id", value: postId)
                .eq("user_id", value: userId)
                .execute()
        } catch { }
    }

    func deletePost(postId: UUID) async {
        do {
            try await client
                .from("forum_posts")
                .delete()
                .eq("id", value: postId)
                .execute()
        } catch { }
    }
}

private struct ForumPostInsert: Encodable {
    let airfieldId: String
    let authorId: UUID
    let authorDisplayName: String
    let content: String
    let category: String
    enum CodingKeys: String, CodingKey {
        case airfieldId = "airfield_id"
        case authorId = "author_id"
        case authorDisplayName = "author_display_name"
        case content
        case category
    }
}

private struct ForumVoteRow: Decodable {
    let postId: UUID
    let vote: String
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case vote
    }
    var voteType: PublicNoteVote.VoteType { PublicNoteVote.VoteType(rawValue: vote) ?? .up }
}

private struct ForumVoteUpsert: Encodable {
    let postId: UUID
    let userId: UUID
    let vote: String
    let updatedAt: Date
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case vote
        case updatedAt = "updated_at"
    }
    init(postId: UUID, userId: UUID, vote: String) {
        self.postId = postId
        self.userId = userId
        self.vote = vote
        self.updatedAt = Date()
    }
}
