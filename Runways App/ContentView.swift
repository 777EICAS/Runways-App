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
    @State private var searchText = ""

    private var airfields: [Airfield] { AirfieldData.allAirfields }

    private var filteredAirfields: [Airfield] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return airfields }
        return airfields.filter {
            $0.name.lowercased().contains(query) ||
            $0.icaoCode.lowercased().contains(query) ||
            ($0.iataCode?.lowercased().contains(query) ?? false)
        }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                AppHeaderView()
                List(filteredAirfields, selection: $selectedAirfield) { airfield in
                    NavigationLink(value: airfield) {
                        AirfieldRowView(airfield: airfield)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: AppTheme.bubbleCornerSmall)
                            .fill(Color.white.opacity(0.5))
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, prompt: "Search by name, IATA or ICAO")
            }
            .navigationTitle("Airfields")
            .navigationBarTitleDisplayMode(.inline)
            .background(SkySunsetBackground())
        } detail: {
            ZStack {
                SkySunsetBackground()
                if let airfield = selectedAirfield {
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
                        description: Text("Search or choose an airfield from the list to view runways and notes.")
                    )
                }
            }
        }
        .tint(AppTheme.skyBlue)
    }
}

#Preview {
    ContentView()
}
