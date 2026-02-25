//
//  AppSettings.swift
//  Runways App
//

import Foundation

/// User preferences for notifications, location, and profile. Persisted to UserDefaults.
@Observable
final class AppSettings {
    private enum Keys {
        static let prefix = "RunwaysApp.Settings."
        static let notificationsEnabled = prefix + "notificationsEnabled"
        static let notifyNearAirfield = prefix + "notifyNearAirfield"
        static let notifyOnNewCommunityPost = prefix + "notifyOnNewCommunityPost"
        static let locationForAirfieldsEnabled = prefix + "locationForAirfieldsEnabled"
        static let displayName = prefix + "displayName"
        static let email = prefix + "email"
    }

    private let defaults = UserDefaults.standard

    /// When true, sync to profile should be skipped (e.g. we're loading from profile).
    var isApplyingProfile = false

    var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    var notifyNearAirfield: Bool {
        didSet {
            defaults.set(notifyNearAirfield, forKey: Keys.notifyNearAirfield)
        }
    }

    var notifyOnNewCommunityPost: Bool {
        didSet {
            defaults.set(notifyOnNewCommunityPost, forKey: Keys.notifyOnNewCommunityPost)
        }
    }

    var locationForAirfieldsEnabled: Bool {
        didSet {
            defaults.set(locationForAirfieldsEnabled, forKey: Keys.locationForAirfieldsEnabled)
        }
    }

    var displayName: String {
        didSet {
            defaults.set(displayName, forKey: Keys.displayName)
        }
    }

    var email: String {
        didSet {
            defaults.set(email, forKey: Keys.email)
        }
    }

    init() {
        self.notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.notifyNearAirfield = defaults.object(forKey: Keys.notifyNearAirfield) as? Bool ?? true
        self.notifyOnNewCommunityPost = defaults.object(forKey: Keys.notifyOnNewCommunityPost) as? Bool ?? true
        self.locationForAirfieldsEnabled = defaults.object(forKey: Keys.locationForAirfieldsEnabled) as? Bool ?? false
        self.displayName = defaults.string(forKey: Keys.displayName) ?? ""
        self.email = defaults.string(forKey: Keys.email) ?? ""
    }

    /// Current settings as ProfileSettings (for sync and comparison).
    var profileSettings: ProfileSettings {
        ProfileSettings(
            notificationsEnabled: notificationsEnabled,
            notifyNearAirfield: notifyNearAirfield,
            notifyOnNewCommunityPost: notifyOnNewCommunityPost,
            locationForAirfieldsEnabled: locationForAirfieldsEnabled
        )
    }

    /// Apply profile data (e.g. after loading from Supabase). Sets isApplyingProfile so sync is skipped.
    func applyFromProfile(displayName: String, email: String, settings: ProfileSettings) {
        isApplyingProfile = true
        self.displayName = displayName
        self.email = email
        self.notificationsEnabled = settings.notificationsEnabled
        self.notifyNearAirfield = settings.notifyNearAirfield
        self.notifyOnNewCommunityPost = settings.notifyOnNewCommunityPost
        self.locationForAirfieldsEnabled = settings.locationForAirfieldsEnabled
        isApplyingProfile = false
    }
}
