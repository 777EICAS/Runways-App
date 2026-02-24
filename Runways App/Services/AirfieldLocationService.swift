//
//  AirfieldLocationService.swift
//  Runways App
//

import CoreLocation
import Foundation
import UserNotifications

/// Uses significant location changes to detect when the user is near an airfield,
/// then schedules a local notification prompting them to add notes.
@Observable
final class AirfieldLocationService: NSObject {
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()

    /// Airfields with coordinates to check against. Defaults to `AirfieldData.allAirfields`.
    var airfields: [Airfield] = AirfieldData.allAirfields

    /// Maximum distance (meters) to consider "at" an airfield. Default 2 km.
    var proximityRadiusMeters: CLLocationDistance = 2000

    /// Cooldown (seconds) before prompting again for the same airfield. Default 24 hours.
    var cooldownInterval: TimeInterval = 24 * 60 * 60

    private let cooldownKeyPrefix = "RunwaysApp.LocationNotePrompt."
    private var isMonitoring = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        // Do not set allowsBackgroundLocationUpdates here — it can throw if the app isn't
        // in a backgroundable state yet. Significant location updates work in background
        // with UIBackgroundModes "location" without this.
    }

    /// Request notification and location permission, then start significant location updates.
    /// Call once when the user opts in (e.g. from settings or first launch).
    func start() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                self?.requestLocationAndStart()
            }
        }
    }

    private func requestLocationAndStart() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startMonitoringIfNeeded()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    func startMonitoringIfNeeded() {
        guard !isMonitoring else { return }
        locationManager.startMonitoringSignificantLocationChanges()
        isMonitoring = true
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        locationManager.stopMonitoringSignificantLocationChanges()
        isMonitoring = false
    }

    private func airfieldsWithCoordinates() -> [Airfield] {
        airfields.filter { $0.latitude != nil && $0.longitude != nil }
    }

    private func nearestAirfield(within radius: CLLocationDistance, from location: CLLocation) -> (airfield: Airfield, distance: CLLocationDistance)? {
        let withCoords = airfieldsWithCoordinates()
        var nearest: (Airfield, CLLocationDistance)?
        for a in withCoords {
            guard let lat = a.latitude, let lon = a.longitude else { continue }
            let coord = CLLocation(latitude: lat, longitude: lon)
            let d = location.distance(from: coord)
            if d <= radius {
                if nearest == nil || d < nearest!.1 {
                    nearest = (a, d)
                }
            }
        }
        return nearest
    }

    private func lastPromptDate(for airfieldId: String) -> Date? {
        UserDefaults.standard.object(forKey: cooldownKeyPrefix + airfieldId) as? Date
    }

    private func setLastPromptDate(_ date: Date, for airfieldId: String) {
        UserDefaults.standard.set(date, forKey: cooldownKeyPrefix + airfieldId)
    }

    private func shouldPrompt(for airfieldId: String) -> Bool {
        guard let last = lastPromptDate(for: airfieldId) else { return true }
        return Date().timeIntervalSince(last) >= cooldownInterval
    }

    private func scheduleNotification(for airfield: Airfield) {
        let content = UNMutableNotificationContent()
        content.title = "Add your notes"
        content.body = "You're near \(airfield.name) — add your notes for this airfield?"
        content.sound = .default
        content.userInfo = ["airfieldId": airfield.id]

        let request = UNNotificationRequest(
            identifier: "location-note-\(airfield.id)-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        notificationCenter.add(request) { _ in }
        setLastPromptDate(Date(), for: airfield.id)
    }
}

extension AirfieldLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if let (airfield, _) = nearestAirfield(within: proximityRadiusMeters, from: location),
           shouldPrompt(for: airfield.id) {
            scheduleNotification(for: airfield)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startMonitoringIfNeeded()
        case .denied, .restricted, .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Significant location is low priority; log in debug if needed
    }
}
