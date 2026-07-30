//
//  PlaceSearching.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/29.
//

import Foundation

protocol PlaceSearching: Sendable {
    func search(query: String) async throws -> [PlaceCoordinate]
}
