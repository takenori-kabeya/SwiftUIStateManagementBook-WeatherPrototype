//
//  OpenMeteoWeatherForecaster.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/30.
//

import Foundation

struct OpenMeteoWeatherForecaster: WeatherForecasting {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> [DailyWeatherForecast] {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(
                name: "daily",
                value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
            ),
            URLQueryItem(name: "forecast_days", value: "3"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]

        guard let url = components?.url else {
            throw WeatherForecastError.requestFailed
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherForecastError.requestFailed
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw WeatherForecastError.requestFailed
        }

        let decoded: OpenMeteoForecastResponse
        do {
            decoded = try JSONDecoder().decode(OpenMeteoForecastResponse.self, from: data)
        } catch {
            throw WeatherForecastError.invalidResponse
        }

        return try decoded.makeDailyForecasts()
    }
}

private struct OpenMeteoForecastResponse: Decodable {
    let daily: OpenMeteoDailyPayload

    func makeDailyForecasts() throws -> [DailyWeatherForecast] {
        let times = daily.time
        let weatherCodes = daily.weatherCode
        let maxTemperatures = daily.temperature2mMax
        let minTemperatures = daily.temperature2mMin
        let precipitationProbabilities = daily.precipitationProbabilityMax

        let count = times.count
        guard
            weatherCodes.count == count,
            maxTemperatures.count == count,
            minTemperatures.count == count,
            precipitationProbabilities.count == count,
            count > 0
        else {
            throw WeatherForecastError.invalidResponse
        }

        return (0..<count).map { index in
            DailyWeatherForecast(
                date: times[index],
                condition: WeatherCondition(weatherCode: weatherCodes[index]),
                maxTemperature: maxTemperatures[index],
                minTemperature: minTemperatures[index],
                precipitationProbability: precipitationProbabilities[index]
            )
        }
    }
}

private struct OpenMeteoDailyPayload: Decodable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationProbabilityMax: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationProbabilityMax = "precipitation_probability_max"
    }
}
