//
//  AppNotificationDelegate.swift
//  Runways App
//

import UserNotifications

/// Handles notification actions (e.g. user taps "add notes" notification).
/// Sets the router's pending airfield id so the UI can open that airfield.
final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private weak var router: NotificationRouter?

    init(router: NotificationRouter) {
        self.router = router
        super.init()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let airfieldId = userInfo["airfieldId"] as? String {
            router?.setPending(airfieldId: airfieldId)
        }
        completionHandler()
    }

    /// Show the notification even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
