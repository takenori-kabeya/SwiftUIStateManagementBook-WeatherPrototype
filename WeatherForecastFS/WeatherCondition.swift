//
//  WeatherCondition.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/30.
//

import Foundation

enum WeatherCondition: Equatable, Sendable {
    case sunny
    case cloudy
    case rainy

    init(weatherCode: Int) {
        switch weatherCode {
        case 0, 1:
            self = .sunny
        case 2, 3, 45, 48:
            self = .cloudy
        default:
            self = .rainy
        }
    }

    var displayName: String {
        switch self {
        case .sunny:
            return "晴れ"
        case .cloudy:
            return "曇り"
        case .rainy:
            return "雨"
        }
    }
}
