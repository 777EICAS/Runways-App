//
//  Runways_AppApp.swift
//  Runways App
//
//  Created by Adam Da Costa on 17/02/2026.
//

import SwiftUI

@main
struct Runways_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                SkySunsetBackground()
                ContentView()
            }
        }
    }
}
