//
//  NotificationRouter.swift
//  Runways App
//

import Foundation

/// Holds pending navigation from a notification tap (e.g. open this airfield).
/// The app's notification delegate sets `pendingAirfieldId` when the user taps
/// a location-based "add notes" notification; the UI observes and navigates.
@Observable
final class NotificationRouter {
    /// When non-nil, the UI should open this airfield and then call `clearPending()`.
    var pendingAirfieldId: String?

    func setPending(airfieldId: String) {
        pendingAirfieldId = airfieldId
    }

    func clearPending() {
        pendingAirfieldId = nil
    }
}
