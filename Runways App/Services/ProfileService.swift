//
//  ProfileService.swift
//  Runways App
//

import Foundation
import Supabase

/// Handles Supabase profile fetch and update. Call from app layer when signed in.
struct ProfileService {
    private let client = SupabaseClient.shared

    /// Fetch the current user's profile. Returns nil if not found or error.
    func fetchProfile(userId: UUID) async -> Profile? {
        do {
            let rows: [Profile] = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            return rows.first
        } catch {
            return nil
        }
    }

    /// Ensure a profile row exists for the user (insert only when missing). Does not overwrite existing profile data.
    func ensureProfileExists(userId: UUID, email: String?, displayName: String?) async {
        guard await fetchProfile(userId: userId) == nil else { return }
        do {
            let payload = ProfileInsert(
                id: userId,
                displayName: displayName ?? "",
                email: email ?? "",
                updatedAt: Date()
            )
            try await client
                .from("profiles")
                .insert(payload)
                .execute()
        } catch {
            // Ignore; trigger may have already created the row
        }
    }

    /// Update display name and email (e.g. when user edits in Settings).
    func updateDisplayNameAndEmail(userId: UUID, displayName: String, email: String) async {
        do {
            let payload = ProfileUpdateDisplayNameEmail(
                displayName: displayName,
                email: email,
                updatedAt: Date()
            )
            try await client
                .from("profiles")
                .update(payload)
                .eq("id", value: userId)
                .execute()
        } catch { }
    }

    /// Update only favourites (e.g. when syncing from FavouritesStore).
    func updateFavourites(userId: UUID, favouriteAirfieldIds: [String]) async {
        do {
            let payload = ProfileUpdateFavourites(
                favouriteAirfieldIds: favouriteAirfieldIds,
                updatedAt: Date()
            )
            try await client
                .from("profiles")
                .update(payload)
                .eq("id", value: userId)
                .execute()
        } catch { }
    }

    /// Update only settings (e.g. when syncing from AppSettings).
    func updateSettings(userId: UUID, settings: ProfileSettings) async {
        do {
            let payload = ProfileUpdateSettings(settings: settings, updatedAt: Date())
            try await client
                .from("profiles")
                .update(payload)
                .eq("id", value: userId)
                .execute()
        } catch { }
    }
}

// MARK: - Encodable payloads for Supabase

private struct ProfileInsert: Encodable {
    let id: UUID
    let displayName: String
    let email: String
    let updatedAt: Date
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case updatedAt = "updated_at"
    }
}

private struct ProfileUpdateDisplayNameEmail: Encodable {
    let displayName: String
    let email: String
    let updatedAt: Date
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case email
        case updatedAt = "updated_at"
    }
}

private struct ProfileUpdateFavourites: Encodable {
    let favouriteAirfieldIds: [String]
    let updatedAt: Date
    enum CodingKeys: String, CodingKey {
        case favouriteAirfieldIds = "favourite_airfield_ids"
        case updatedAt = "updated_at"
    }
}

private struct ProfileUpdateSettings: Encodable {
    let settings: ProfileSettings
    let updatedAt: Date
    enum CodingKeys: String, CodingKey {
        case settings
        case updatedAt = "updated_at"
    }
}
