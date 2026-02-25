//
//  ForumRealtimeService.swift
//  Runways App
//

import Foundation
import Supabase
import UserNotifications

/// Subscribes to new forum_posts via Realtime and schedules a local notification when someone
/// posts on an airfield the current user has favourited (and they are not the author).
@Observable
final class ForumRealtimeService {
    private let client = SupabaseClient.shared
    private let notificationCenter = UNUserNotificationCenter.current()

    private var channel: RealtimeChannelV2?
    private var listenTask: Task<Void, Never>?

    /// Call when signed in with favourites; pass current state. Call stop() when signed out or when notifications disabled.
    func start(
        currentUserId: UUID,
        favouriteAirfieldIds: Set<String>,
        notificationsEnabled: Bool,
        notifyOnNewCommunityPost: Bool,
        airfieldName: @escaping (String) -> String
    ) {
        stop()
        guard notificationsEnabled, notifyOnNewCommunityPost, !favouriteAirfieldIds.isEmpty else { return }

        let channelName = "forum-posts-\(currentUserId.uuidString)"
        let ch = client.channel(channelName)
        self.channel = ch

        // Register postgres listener before subscribing (required by Realtime).
        let stream = ch.postgresChange(InsertAction.self, schema: "public", table: "forum_posts")
        listenTask = Task { [weak self] in
            guard let self else { return }
            for await action in stream {
                await MainActor.run {
                    self.handleNewPost(
                        action: action,
                        currentUserId: currentUserId,
                        favouriteAirfieldIds: favouriteAirfieldIds,
                        airfieldName: airfieldName
                    )
                }
            }
        }

        Task {
            try? await ch.subscribeWithError()
        }
    }

    func stop() {
        listenTask?.cancel()
        listenTask = nil
        if let channel {
            Task {
                await client.removeChannel(channel)
            }
        }
        channel = nil
    }

    @MainActor
    private func handleNewPost(
        action: InsertAction,
        currentUserId: UUID,
        favouriteAirfieldIds: Set<String>,
        airfieldName: (String) -> String
    ) {
        struct Record: Decodable {
            let airfieldId: String
            let authorId: UUID
            enum CodingKeys: String, CodingKey {
                case airfieldId = "airfield_id"
                case authorId = "author_id"
            }
        }
        guard let row = try? action.decodeRecord(as: Record.self, decoder: JSONDecoder()) else { return }
        guard favouriteAirfieldIds.contains(row.airfieldId) else { return }
        if row.authorId == currentUserId { return }

        let airfieldId = row.airfieldId

        let name = airfieldName(airfieldId)
        let content = UNMutableNotificationContent()
        content.title = "New community post"
        content.body = "Someone posted on \(name)"
        content.sound = .default
        content.userInfo = ["airfieldId": airfieldId]

        let request = UNNotificationRequest(
            identifier: "forum-post-\(airfieldId)-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        notificationCenter.add(request) { _ in }
    }
}
