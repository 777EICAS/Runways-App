//
//  FavouritesStore.swift
//  Runways App
//

import Foundation

@Observable
final class FavouritesStore {
    private(set) var favouriteIds: Set<String> = []
    private let key = "RunwaysApp.FavouriteAirfieldIds"

    init() {
        if let array = UserDefaults.standard.array(forKey: key) as? [String] {
            favouriteIds = Set(array)
        }
    }

    func isFavourite(_ airfieldId: String) -> Bool {
        favouriteIds.contains(airfieldId)
    }

    func toggle(_ airfieldId: String) {
        if favouriteIds.contains(airfieldId) {
            favouriteIds.remove(airfieldId)
        } else {
            favouriteIds.insert(airfieldId)
        }
        save()
    }

    func setFavourite(_ airfieldId: String, isOn: Bool) {
        if isOn {
            favouriteIds.insert(airfieldId)
        } else {
            favouriteIds.remove(airfieldId)
        }
        save()
    }

    private func save() {
        let array = Array(favouriteIds)
        UserDefaults.standard.set(array, forKey: key)
    }
}
