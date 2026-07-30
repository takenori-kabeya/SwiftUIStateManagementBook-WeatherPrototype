//
//  DailyWeatherForecast.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/30.
//

import Foundation

struct DailyWeatherForecast: Identifiable, Equatable, Sendable {
    var id: String { date }
    let date: String
    let condition: WeatherCondition
    let maxTemperature: Double
    let minTemperature: Double
    let precipitationProbability: Int
}
