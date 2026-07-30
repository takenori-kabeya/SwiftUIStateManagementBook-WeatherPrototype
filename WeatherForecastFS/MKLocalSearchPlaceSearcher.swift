//
//  MKLocalSearchPlaceSearcher.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/29.
//

import Foundation
import MapKit

struct MKLocalSearchPlaceSearcher: PlaceSearching {
    func search(query: String) async throws -> [PlaceCoordinate] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        do {
            let response = try await MKLocalSearch(request: request).start()
            let places = response.mapItems.enumerated().compactMap { index, item -> PlaceCoordinate? in
                let name = item.name?.trimmingCharacters(in: .whitespacesAndNewlines)
                let displayName: String
                if let name, !name.isEmpty {
                    displayName = name
                } else {
                    return nil
                }

                let coordinate = item.location.coordinate
                return PlaceCoordinate(
                    id: "\(index)-\(displayName)-\(coordinate.latitude)-\(coordinate.longitude)",
                    name: displayName,
                    address: item.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true) ?? "",
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            }

            guard !places.isEmpty else {
                throw PlaceSearchError.notFound
            }
            return places
        } catch let error as PlaceSearchError {
            throw error
        } catch {
            throw PlaceSearchError.searchFailed
        }
    }
}
