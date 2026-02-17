//
//  ContentView.swift
//  Runways App
//

import SwiftUI

enum AirfieldListMode: String, CaseIterable {
    case all = "All"
    case favourites = "Favourites"
    case myNotes = "My notes"
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
    @State private var expandedNotesAirfieldIds: Set<String> = []

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

    /// Airfields to display: all, favourites, or only those with at least one of the user's notes.
    private var displayedAirfields: [Airfield] {
        switch listMode {
        case .all: return filteredAirfields
        case .favourites: return filteredAirfields.filter { favouritesStore.isFavourite($0.id) }
        case .myNotes:
            let idsWithNotes = privateNotesStore.airfieldIdsWithNotes()
            return filteredAirfields.filter { idsWithNotes.contains($0.id) }
        }
    }

    /// When editing favourites, show all filtered airfields with tick state. Otherwise show displayed list.
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
                    } else if listMode == .myNotes && displayedAirfields.isEmpty {
                        ContentUnavailableView(
                            "No notes yet",
                            systemImage: "note.text",
                            description: Text("Open an airfield and add a note in **My notes** to see it here.")
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
        } else if listMode == .myNotes {
            myNotesRow(airfield: airfield)
        } else {
            NavigationLink(value: airfield) {
                AirfieldRowView(airfield: airfield)
            }
            .listRowBackground(rowBackground)
            .listRowInsets(rowInsets)
        }
    }

    /// My notes tab: airfield name (not a link), notes in dropdown for quick access; optional link to full airfield.
    @ViewBuilder
    private func myNotesRow(airfield: Airfield) -> some View {
        let notesAtAirfield = privateNotesStore.notes(for: airfield.id)
        let isExpanded = expandedNotesAirfieldIds.contains(airfield.id)

        VStack(alignment: .leading, spacing: 0) {
            // Airfield name only – not a link; just identifies which airfield the notes belong to.
            HStack {
                AirfieldRowView(airfield: airfield)
                Spacer()
            }

            // Dropdown: tap to expand and see your notes without leaving the list.
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded { expandedNotesAirfieldIds.remove(airfield.id) }
                    else { expandedNotesAirfieldIds.insert(airfield.id) }
                }
            } label: {
                HStack {
                    Image(systemName: "note.text")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.coral)
                    Text("My notes (\(notesAtAirfield.count))")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.vertical, 8)
                .padding(.leading, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(notesAtAirfield) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            if !note.body.isEmpty {
                                Text(note.body)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(4)
                            }
                            Text(note.category.displayName)
                                .font(.caption2)
                                .foregroundStyle(AppTheme.coral)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(AppTheme.coralLight.opacity(0.5)))
                    }
                    Button {
                        selectedAirfield = airfield
                    } label: {
                        Label("Open full airfield", systemImage: "arrow.right.circle")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.skyBlue)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .padding(.bottom, 8)
            }
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: AppTheme.bubbleCornerSmall)
                .fill(Color.white.opacity(0.5))
        )
        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
    }
}

#Preview {
    ContentView()
}
