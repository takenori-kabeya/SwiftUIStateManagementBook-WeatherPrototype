//
//  PlaceSearchViewModel.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/29.
//

import Foundation
import Observation

@MainActor
@Observable
final class PlaceSearchViewModel {
    var query: String = ""
    var candidates: [PlaceCoordinate] = []
    var selectedPlace: PlaceCoordinate?
    var errorMessage: String?
    var isSearching: Bool = false

    var dailyForecasts: [DailyWeatherForecast] = []
    var forecastErrorMessage: String?
    var isFetchingForecast: Bool = false

    private let searcher: any PlaceSearching
    private let forecaster: any WeatherForecasting

    init(
        searcher: any PlaceSearching = MKLocalSearchPlaceSearcher(),
        forecaster: any WeatherForecasting = OpenMeteoWeatherForecaster()
    ) {
        self.searcher = searcher
        self.forecaster = forecaster
    }

    func search() async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            candidates = []
            selectedPlace = nil
            clearForecastState()
            errorMessage = PlaceSearchError.emptyQuery.localizedDescription
            return
        }

        isSearching = true
        errorMessage = nil
        clearForecastState()
        defer { isSearching = false }

        do {
            let places = try await searcher.search(query: trimmedQuery)
            applySearchResults(places)
        } catch let error as PlaceSearchError {
            candidates = []
            selectedPlace = nil
            errorMessage = error.localizedDescription
        } catch {
            candidates = []
            selectedPlace = nil
            errorMessage = PlaceSearchError.searchFailed.localizedDescription
        }
    }

    func select(_ place: PlaceCoordinate) {
        selectedPlace = place
        errorMessage = nil
        clearForecastState()
    }

    func fetchWeatherForecast() async {
        guard let selectedPlace else {
            dailyForecasts = []
            forecastErrorMessage = WeatherForecastError.noPlaceSelected.localizedDescription
            return
        }

        isFetchingForecast = true
        forecastErrorMessage = nil
        defer { isFetchingForecast = false }

        do {
            let forecasts = try await forecaster.fetchForecast(
                latitude: selectedPlace.latitude,
                longitude: selectedPlace.longitude
            )
            dailyForecasts = forecasts
            forecastErrorMessage = nil
        } catch let error as WeatherForecastError {
            dailyForecasts = []
            forecastErrorMessage = error.localizedDescription
        } catch {
            dailyForecasts = []
            forecastErrorMessage = WeatherForecastError.requestFailed.localizedDescription
        }
    }

    private func applySearchResults(_ places: [PlaceCoordinate]) {
        switch places.count {
        case 0:
            candidates = []
            selectedPlace = nil
            errorMessage = PlaceSearchError.notFound.localizedDescription
        case 1:
            candidates = []
            selectedPlace = places[0]
            errorMessage = nil
        default:
            candidates = places
            selectedPlace = nil
            errorMessage = nil
        }
    }

    private func clearForecastState() {
        dailyForecasts = []
        forecastErrorMessage = nil
    }
}
