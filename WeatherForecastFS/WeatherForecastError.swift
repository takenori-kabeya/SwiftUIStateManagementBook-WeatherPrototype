//
//  WeatherForecastError.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/30.
//

import Foundation

enum WeatherForecastError: LocalizedError, Equatable {
    case noPlaceSelected
    case invalidResponse
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .noPlaceSelected:
            return "場所が選択されていません。"
        case .invalidResponse:
            return "天気予報の応答形式が不正です。"
        case .requestFailed:
            return "天気予報の取得に失敗しました。"
        }
    }
}
