//
//  ContentView.swift
//  Runways App
//

import SwiftUI

struct ContentView: View {
    @State private var privateNotesStore = PrivateNotesStore()
    @State private var publicBoardStore = PublicBoardStore()
    @State private var networkMonitor = NetworkMonitor()
    @State private var selectedAirfield: Airfield?

    private var airfields: [Airfield] { AirfieldData.allAirfields }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                AppHeaderView()
                List(airfields, selection: $selectedAirfield) { airfield in
                    NavigationLink(value: airfield) {
                        AirfieldRowView(airfield: airfield)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: AppTheme.bubbleCornerSmall)
                            .fill(AppTheme.skyBlueLight.opacity(0.3))
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                .listStyle(.plain)
            }
            .navigationTitle("Airfields")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    colors: [AppTheme.skyBlueLight.opacity(0.15), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        } detail: {
            if let airfield = selectedAirfield ?? airfields.first {
                AirfieldDetailView(
                    airfield: airfield,
                    privateNotesStore: privateNotesStore,
                    publicBoardStore: publicBoardStore,
                    isOnline: networkMonitor.isConnected
                )
            } else {
                ContentUnavailableView(
                    "Select an airfield",
                    systemImage: "airplane.departure",
                    description: Text("Choose an airfield from the list to view runways and notes.")
                )
            }
        }
        .tint(AppTheme.skyBlue)
        .onAppear {
            if selectedAirfield == nil, let first = airfields.first {
                selectedAirfield = first
            }
        }
    }
}

#Preview {
    ContentView()
}
