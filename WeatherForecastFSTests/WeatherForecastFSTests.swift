//
//  WeatherForecastFSTests.swift
//  WeatherForecastFSTests
//
//  Created by Takenori Kabeya on 2026/07/29.
//

import Foundation
import Testing
@testable import WeatherForecastFS

@MainActor
struct WeatherForecastFSTests {

    @Test func searchWithEmptyQuerySetsEmptyQueryError() async {
        let searcher = MockPlaceSearcher(result: .success([]))
        let viewModel = PlaceSearchViewModel(searcher: searcher)
        viewModel.query = "   "

        await viewModel.search()

        #expect(searcher.searchCallCount == 0)
        #expect(viewModel.candidates.isEmpty)
        #expect(viewModel.selectedPlace == nil)
        #expect(viewModel.errorMessage == PlaceSearchError.emptyQuery.localizedDescription)
        #expect(viewModel.isSearching == false)
    }

    @Test func searchWithSingleResultAutoSelectsPlace() async {
        let place = PlaceCoordinate(
            id: "1",
            name: "東京駅",
            latitude: 35.6812,
            longitude: 139.7671
        )
        let searcher = MockPlaceSearcher(result: .success([place]))
        let viewModel = PlaceSearchViewModel(searcher: searcher)
        viewModel.query = "東京駅"

        await viewModel.search()

        #expect(searcher.searchCallCount == 1)
        #expect(searcher.lastQuery == "東京駅")
        #expect(viewModel.candidates.isEmpty)
        #expect(viewModel.selectedPlace == place)
        #expect(viewModel.selectedPlace?.latitude == 35.6812)
        #expect(viewModel.selectedPlace?.longitude == 139.7671)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isSearching == false)
    }

    @Test func searchWithMultipleResultsKeepsCandidatesWithoutSelection() async {
        let places = [
            PlaceCoordinate(id: "1", name: "大阪駅", latitude: 34.7024, longitude: 135.4959),
            PlaceCoordinate(id: "2", name: "大阪城", latitude: 34.6873, longitude: 135.5262),
        ]
        let searcher = MockPlaceSearcher(result: .success(places))
        let viewModel = PlaceSearchViewModel(searcher: searcher)
        viewModel.query = "大阪"

        await viewModel.search()

        #expect(viewModel.candidates == places)
        #expect(viewModel.selectedPlace == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func selectSetsSelectedPlaceFromCandidates() async {
        let places = [
            PlaceCoordinate(id: "1", name: "大阪駅", latitude: 34.7024, longitude: 135.4959),
            PlaceCoordinate(id: "2", name: "大阪城", latitude: 34.6873, longitude: 135.5262),
        ]
        let searcher = MockPlaceSearcher(result: .success(places))
        let viewModel = PlaceSearchViewModel(searcher: searcher)
        viewModel.query = "大阪"
        await viewModel.search()

        viewModel.select(places[1])

        #expect(viewModel.selectedPlace == places[1])
        #expect(viewModel.selectedPlace?.latitude == 34.6873)
        #expect(viewModel.selectedPlace?.longitude == 135.5262)
        #expect(viewModel.candidates == places)
    }

    @Test func searchWithNoResultsSetsNotFoundError() async {
        let searcher = MockPlaceSearcher(result: .failure(PlaceSearchError.notFound))
        let viewModel = PlaceSearchViewModel(searcher: searcher)
        viewModel.query = "存在しない地名XYZ"
        viewModel.candidates = [
            PlaceCoordinate(id: "old", name: "旧候補", latitude: 0, longitude: 0)
        ]
        viewModel.selectedPlace = PlaceCoordinate(id: "old", name: "旧候補", latitude: 0, longitude: 0)

        await viewModel.search()

        #expect(viewModel.candidates.isEmpty)
        #expect(viewModel.selectedPlace == nil)
        #expect(viewModel.errorMessage == PlaceSearchError.notFound.localizedDescription)
    }

    @Test func searchWithFailureSetsSearchFailedError() async {
        let searcher = MockPlaceSearcher(result: .failure(PlaceSearchError.searchFailed))
        let viewModel = PlaceSearchViewModel(searcher: searcher)
        viewModel.query = "東京"

        await viewModel.search()

        #expect(viewModel.candidates.isEmpty)
        #expect(viewModel.selectedPlace == nil)
        #expect(viewModel.errorMessage == PlaceSearchError.searchFailed.localizedDescription)
    }

    @Test func fetchWeatherForecastWithoutSelectedPlaceSetsErrorAndDoesNotCallAPI() async {
        let forecaster = MockWeatherForecaster(result: .success([]))
        let viewModel = PlaceSearchViewModel(
            searcher: MockPlaceSearcher(result: .success([])),
            forecaster: forecaster
        )

        await viewModel.fetchWeatherForecast()

        #expect(forecaster.fetchCallCount == 0)
        #expect(viewModel.dailyForecasts.isEmpty)
        #expect(viewModel.forecastErrorMessage == WeatherForecastError.noPlaceSelected.localizedDescription)
        #expect(viewModel.isFetchingForecast == false)
    }

    @Test func fetchWeatherForecastSetsThreeDailyForecasts() async {
        let forecasts = [
            DailyWeatherForecast(
                date: "2026-07-30",
                condition: .sunny,
                maxTemperature: 30.0,
                minTemperature: 22.0,
                precipitationProbability: 10
            ),
            DailyWeatherForecast(
                date: "2026-07-31",
                condition: .cloudy,
                maxTemperature: 28.0,
                minTemperature: 21.0,
                precipitationProbability: 40
            ),
            DailyWeatherForecast(
                date: "2026-08-01",
                condition: .rainy,
                maxTemperature: 25.0,
                minTemperature: 20.0,
                precipitationProbability: 80
            ),
        ]
        let place = PlaceCoordinate(
            id: "1",
            name: "東京駅",
            latitude: 35.6812,
            longitude: 139.7671
        )
        let forecaster = MockWeatherForecaster(result: .success(forecasts))
        let viewModel = PlaceSearchViewModel(
            searcher: MockPlaceSearcher(result: .success([place])),
            forecaster: forecaster
        )
        viewModel.selectedPlace = place

        await viewModel.fetchWeatherForecast()

        #expect(forecaster.fetchCallCount == 1)
        #expect(forecaster.lastLatitude == 35.6812)
        #expect(forecaster.lastLongitude == 139.7671)
        #expect(viewModel.dailyForecasts.count == 3)
        #expect(viewModel.dailyForecasts[0].condition == .sunny)
        #expect(viewModel.dailyForecasts[0].maxTemperature == 30.0)
        #expect(viewModel.dailyForecasts[0].minTemperature == 22.0)
        #expect(viewModel.dailyForecasts[0].precipitationProbability == 10)
        #expect(viewModel.dailyForecasts[1].condition == .cloudy)
        #expect(viewModel.dailyForecasts[2].condition == .rainy)
        #expect(viewModel.dailyForecasts[2].precipitationProbability == 80)
        #expect(viewModel.forecastErrorMessage == nil)
        #expect(viewModel.isFetchingForecast == false)
    }

    @Test func weatherConditionMapsWMOCodes() {
        #expect(WeatherCondition(weatherCode: 0) == .sunny)
        #expect(WeatherCondition(weatherCode: 1) == .sunny)
        #expect(WeatherCondition(weatherCode: 3) == .cloudy)
        #expect(WeatherCondition(weatherCode: 45) == .cloudy)
        #expect(WeatherCondition(weatherCode: 61) == .rainy)
        #expect(WeatherCondition(weatherCode: 0).displayName == "晴れ")
        #expect(WeatherCondition(weatherCode: 3).displayName == "曇り")
        #expect(WeatherCondition(weatherCode: 61).displayName == "雨")
    }

    @Test func fetchWeatherForecastFailureClearsForecastsAndSetsError() async {
        let place = PlaceCoordinate(
            id: "1",
            name: "東京駅",
            latitude: 35.6812,
            longitude: 139.7671
        )
        let forecaster = MockWeatherForecaster(result: .failure(WeatherForecastError.requestFailed))
        let viewModel = PlaceSearchViewModel(
            searcher: MockPlaceSearcher(result: .success([place])),
            forecaster: forecaster
        )
        viewModel.selectedPlace = place
        viewModel.dailyForecasts = [
            DailyWeatherForecast(
                date: "2026-07-30",
                condition: .sunny,
                maxTemperature: 30.0,
                minTemperature: 22.0,
                precipitationProbability: 10
            )
        ]

        await viewModel.fetchWeatherForecast()

        #expect(viewModel.dailyForecasts.isEmpty)
        #expect(viewModel.forecastErrorMessage == WeatherForecastError.requestFailed.localizedDescription)
        #expect(viewModel.isFetchingForecast == false)
    }

    @Test func selectClearsPreviousForecastAndForecastError() async {
        let places = [
            PlaceCoordinate(id: "1", name: "大阪駅", latitude: 34.7024, longitude: 135.4959),
            PlaceCoordinate(id: "2", name: "大阪城", latitude: 34.6873, longitude: 135.5262),
        ]
        let viewModel = PlaceSearchViewModel(
            searcher: MockPlaceSearcher(result: .success(places)),
            forecaster: MockWeatherForecaster(result: .success([]))
        )
        viewModel.selectedPlace = places[0]
        viewModel.dailyForecasts = [
            DailyWeatherForecast(
                date: "2026-07-30",
                condition: .sunny,
                maxTemperature: 30.0,
                minTemperature: 22.0,
                precipitationProbability: 10
            )
        ]
        viewModel.forecastErrorMessage = "古いエラー"

        viewModel.select(places[1])

        #expect(viewModel.selectedPlace == places[1])
        #expect(viewModel.dailyForecasts.isEmpty)
        #expect(viewModel.forecastErrorMessage == nil)
    }

    @Test func searchClearsPreviousForecastAndForecastError() async {
        let place = PlaceCoordinate(
            id: "1",
            name: "東京駅",
            latitude: 35.6812,
            longitude: 139.7671
        )
        let viewModel = PlaceSearchViewModel(
            searcher: MockPlaceSearcher(result: .success([place])),
            forecaster: MockWeatherForecaster(result: .success([]))
        )
        viewModel.dailyForecasts = [
            DailyWeatherForecast(
                date: "2026-07-30",
                condition: .sunny,
                maxTemperature: 30.0,
                minTemperature: 22.0,
                precipitationProbability: 10
            )
        ]
        viewModel.forecastErrorMessage = "古いエラー"
        viewModel.query = "東京駅"

        await viewModel.search()

        #expect(viewModel.dailyForecasts.isEmpty)
        #expect(viewModel.forecastErrorMessage == nil)
    }
}

final class MockPlaceSearcher: PlaceSearching, @unchecked Sendable {
    var result: Result<[PlaceCoordinate], Error>
    private(set) var searchCallCount = 0
    private(set) var lastQuery: String?

    init(result: Result<[PlaceCoordinate], Error>) {
        self.result = result
    }

    func search(query: String) async throws -> [PlaceCoordinate] {
        searchCallCount += 1
        lastQuery = query
        return try result.get()
    }
}

final class MockWeatherForecaster: WeatherForecasting, @unchecked Sendable {
    var result: Result<[DailyWeatherForecast], Error>
    private(set) var fetchCallCount = 0
    private(set) var lastLatitude: Double?
    private(set) var lastLongitude: Double?

    init(result: Result<[DailyWeatherForecast], Error>) {
        self.result = result
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> [DailyWeatherForecast] {
        fetchCallCount += 1
        lastLatitude = latitude
        lastLongitude = longitude
        return try result.get()
    }
}
