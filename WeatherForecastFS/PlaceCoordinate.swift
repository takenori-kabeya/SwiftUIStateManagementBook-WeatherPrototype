//
//  PlaceCoordinate.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/29.
//

import Foundation

struct PlaceCoordinate: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double

    init(
        id: String,
        name: String,
        address: String = "",
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
