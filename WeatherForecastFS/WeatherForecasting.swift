//
//  WeatherForecasting.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/30.
//

import Foundation

protocol WeatherForecasting: Sendable {
    func fetchForecast(latitude: Double, longitude: Double) async throws -> [DailyWeatherForecast]
}
