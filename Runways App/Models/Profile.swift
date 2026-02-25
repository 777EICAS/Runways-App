//
//  Profile.swift
//  Runways App
//

import Foundation

/// Profile row from Supabase public.profiles.
struct Profile: Codable {
    var id: UUID
    var displayName: String
    var email: String
    var settings: ProfileSettings
    var favouriteAirfieldIds: [String]
    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case settings
        case favouriteAirfieldIds = "favourite_airfield_ids"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Settings JSON stored in profiles.settings.
struct ProfileSettings: Codable, Equatable {
    var notificationsEnabled: Bool
    var notifyNearAirfield: Bool
    var notifyOnNewCommunityPost: Bool
    var locationForAirfieldsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case notificationsEnabled
        case notifyNearAirfield
        case notifyOnNewCommunityPost
        case locationForAirfieldsEnabled
    }

    init(notificationsEnabled: Bool, notifyNearAirfield: Bool, notifyOnNewCommunityPost: Bool, locationForAirfieldsEnabled: Bool) {
        self.notificationsEnabled = notificationsEnabled
        self.notifyNearAirfield = notifyNearAirfield
        self.notifyOnNewCommunityPost = notifyOnNewCommunityPost
        self.locationForAirfieldsEnabled = locationForAirfieldsEnabled
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        notificationsEnabled = try c.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
        notifyNearAirfield = try c.decodeIfPresent(Bool.self, forKey: .notifyNearAirfield) ?? true
        notifyOnNewCommunityPost = try c.decodeIfPresent(Bool.self, forKey: .notifyOnNewCommunityPost) ?? true
        locationForAirfieldsEnabled = try c.decodeIfPresent(Bool.self, forKey: .locationForAirfieldsEnabled) ?? false
    }
}
