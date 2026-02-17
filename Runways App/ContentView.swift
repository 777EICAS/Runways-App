//
//  ContentView.swift
//  Runways App
//

import SwiftUI

enum AirfieldListMode: String, CaseIterable {
    case all = "All"
    case favourites = "Favourites"
}

struct ContentView: View {
    @State private var privateNotesStore = PrivateNotesStore()
    @State private var publicBoardStore = PublicBoardStore()
    @State private var networkMonitor = NetworkMonitor()
    @State private var favouritesStore = FavouritesStore()
    @State private var selectedAirfield: Airfield?
    @State private var searchText = ""
    @State private var listMode: AirfieldListMode = .all
    @State private var isEditingFavourites = false

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

    /// Airfields to display: either all (filtered) or only favourites (filtered).
    private var displayedAirfields: [Airfield] {
        switch listMode {
        case .all: return filteredAirfields
        case .favourites: return filteredAirfields.filter { favouritesStore.isFavourite($0.id) }
        }
    }

    /// When editing favourites, show all filtered airfields with tick state. Otherwise show displayed (all or favourites).
    private var listSourceForDisplay: [Airfield] {
        isEditingFavourites ? filteredAirfields : displayedAirfields
    }

    /// Group airfields by region for section headers.
    private func groupedByRegion(_ list: [Airfield]) -> [(String, [Airfield])] {
        let grouped = Dictionary(grouping: list) { $0.region ?? "Other" }
        return grouped.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                AppHeaderView()
                Picker("List", selection: $listMode) {
                    ForEach(AirfieldListMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                List(selection: $selectedAirfield) {
                    if listMode == .favourites && !isEditingFavourites && displayedAirfields.isEmpty {
                        ContentUnavailableView(
                            "No favourites",
                            systemImage: "star",
                            description: Text("Tap Edit to select favourite airfields.")
                        )
                    } else {
                        ForEach(groupedByRegion(listSourceForDisplay), id: \.0) { region, regionAirfields in
                            Section {
                                ForEach(regionAirfields) { airfield in
                                    row(for: airfield, region: region)
                                }
                            } header: {
                                Text(region)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.skyBlue)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, prompt: "Search by name, IATA or ICAO")
            }
            .navigationTitle("Airfields")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if listMode == .favourites {
                    ToolbarItem(placement: .primaryAction) {
                        Button(isEditingFavourites ? "Done" : "Edit") {
                            isEditingFavourites.toggle()
                        }
                    }
                }
            }
            .background(SkySunsetBackground())
        } detail: {
            Group {
                if let airfield = selectedAirfield {
                    NavigationStack {
                        AirfieldDetailView(
                            airfield: airfield,
                            privateNotesStore: privateNotesStore,
                            publicBoardStore: publicBoardStore,
                            isOnline: networkMonitor.isConnected
                        )
                    }
                } else {
                    ZStack {
                        SkySunsetBackground()
                        ContentUnavailableView(
                            "Select an airfield",
                            systemImage: "airplane.departure",
                            description: Text("Search or choose an airfield from the list to view runways and notes.")
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .tint(AppTheme.skyBlue)
    }

    @ViewBuilder
    private func row(for airfield: Airfield, region: String) -> some View {
        let rowBackground = RoundedRectangle(cornerRadius: AppTheme.bubbleCornerSmall)
            .fill(Color.white.opacity(0.5))
        let rowInsets = EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)

        if isEditingFavourites {
            Button {
                favouritesStore.toggle(airfield.id)
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: favouritesStore.isFavourite(airfield.id) ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(favouritesStore.isFavourite(airfield.id) ? AppTheme.skyBlue : .secondary)
                    AirfieldRowView(airfield: airfield)
                }
            }
            .buttonStyle(.plain)
            .listRowBackground(rowBackground)
            .listRowInsets(rowInsets)
        } else {
            NavigationLink(value: airfield) {
                AirfieldRowView(airfield: airfield)
            }
            .listRowBackground(rowBackground)
            .listRowInsets(rowInsets)
        }
    }
}

#Preview {
    ContentView()
}
