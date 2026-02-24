//
//  Runways_AppApp.swift
//  Runways App
//
//  Created by Adam Da Costa on 17/02/2026.
//

import SwiftUI

@main
struct Runways_AppApp: App {
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
            .environment(notificationRouter)
            .onAppear {
                notificationDelegate = AppNotificationDelegate(router: notificationRouter)
                UNUserNotificationCenter.current().delegate = notificationDelegate
                locationService.start()
            }
        }
    }
}
