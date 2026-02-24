//
//  Runways_AppApp.swift
//  Runways App
//
//  Created by Adam Da Costa on 17/02/2026.
//

import SwiftUI

@main
struct Runways_AppApp: App {
    @State private var appSettings = AppSettings()
    @State private var notificationRouter = NotificationRouter()
    @State private var locationService = AirfieldLocationService()
    /// Strong reference so the notification center’s weak delegate is not deallocated.
    @State private var notificationDelegate: AppNotificationDelegate?

    var body: some Scene {
        WindowGroup {
            ZStack {
                SkySunsetBackground()
                ContentView(notificationRouter: notificationRouter)
            }
            .environment(appSettings)
            .environment(locationService)
            .environment(notificationRouter)
            .onAppear {
                notificationDelegate = AppNotificationDelegate(router: notificationRouter)
                UNUserNotificationCenter.current().delegate = notificationDelegate
                locationService.settings = appSettings
                applyLocationPreference()
            }
            .onChange(of: appSettings.locationForAirfieldsEnabled) { _, _ in
                applyLocationPreference()
            }
        }
    }

    private func applyLocationPreference() {
        if appSettings.locationForAirfieldsEnabled {
            locationService.start()
        } else {
            locationService.stopMonitoring()
        }
    }
}
