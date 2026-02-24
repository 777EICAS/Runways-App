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
        static let locationForAirfieldsEnabled = prefix + "locationForAirfieldsEnabled"
        static let displayName = prefix + "displayName"
        static let email = prefix + "email"
    }

    private let defaults = UserDefaults.standard

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
        self.locationForAirfieldsEnabled = defaults.object(forKey: Keys.locationForAirfieldsEnabled) as? Bool ?? false
        self.displayName = defaults.string(forKey: Keys.displayName) ?? ""
        self.email = defaults.string(forKey: Keys.email) ?? ""
    }
}
