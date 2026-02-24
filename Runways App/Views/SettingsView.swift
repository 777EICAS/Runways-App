//
//  SettingsView.swift
//  Runways App
//

import CoreLocation
import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settings: AppSettings
    var locationService: AirfieldLocationService

    var body: some View {
        NavigationStack {
            Form {
                notificationsSection
                locationSection
                profileSection
            }
            .scrollContentBackground(.hidden)
            .background(SkySunsetBackground())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.skyBlue)
                }
            }
            .tint(AppTheme.skyBlue)
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Allow notifications", isOn: $settings.notificationsEnabled)
            Toggle("Notify when near an airfield", isOn: $settings.notifyNearAirfield)
                .disabled(!settings.notificationsEnabled)
        } header: {
            Label("Notifications", systemImage: "bell")
        } footer: {
            Text("When enabled, you can get a reminder to add notes when you're near an airfield.")
        }
        .listRowBackground(AppTheme.cardFill)
    }

    private var locationSection: some View {
        Section {
            Toggle("Use location for nearby airfields", isOn: $settings.locationForAirfieldsEnabled)
            HStack {
                Text("Status")
                Spacer()
                Text(locationStatusText)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.trailing)
            }
            .listRowBackground(AppTheme.cardFill)
            if locationService.locationAuthorizationStatus == .denied ||
               locationService.locationAuthorizationStatus == .restricted {
                Button("Open Settings") {
                    openAppSettings()
                }
                .foregroundStyle(AppTheme.skyBlue)
                .listRowBackground(AppTheme.cardFill)
            }
        } header: {
            Label("Location", systemImage: "location")
        } footer: {
            Text("Location is used to remind you to add notes when you're near an airfield. You can turn this off at any time.")
        }
        .listRowBackground(AppTheme.cardFill)
    }

    private var profileSection: some View {
        Section {
            TextField("Display name", text: $settings.displayName)
                .textContentType(.name)
                .autocapitalization(.words)
            TextField("Email", text: $settings.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        } header: {
            Label("Profile", systemImage: "person")
        } footer: {
            Text("Optional. Used to personalise your experience.")
        }
        .listRowBackground(AppTheme.cardFill)
    }

    private var locationStatusText: String {
        switch locationService.locationAuthorizationStatus {
        case .notDetermined: return "Not determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When in use"
        @unknown default: return "Unknown"
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    SettingsView(
        settings: AppSettings(),
        locationService: AirfieldLocationService()
    )
}
