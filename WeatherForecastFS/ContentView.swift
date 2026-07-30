//
//  ContentView.swift
//  WeatherForecastFS
//
//  Created by Takenori Kabeya on 2026/07/29.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = PlaceSearchViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("地名検索") {
                    TextField("地名を入力", text: $viewModel.query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            Task { await viewModel.search() }
                        }

                    Button {
                        Task { await viewModel.search() }
                    } label: {
                        if viewModel.isSearching {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("検索")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isSearching)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                if !viewModel.candidates.isEmpty {
                    Section("候補") {
                        ForEach(viewModel.candidates) { place in
                            Button {
                                viewModel.select(place)
                            } label: {
                                HStack {
                                    Text(place.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if viewModel.selectedPlace == place {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                        }
                    }
                }

                if let selectedPlace = viewModel.selectedPlace {
                    Section("選択した場所") {
                        LabeledContent("地名", value: selectedPlace.name)
                        LabeledContent("住所", value: selectedPlace.address)
                        LabeledContent("緯度", value: formatCoordinate(selectedPlace.latitude))
                        LabeledContent("経度", value: formatCoordinate(selectedPlace.longitude))

                        Button {
                            Task { await viewModel.fetchWeatherForecast() }
                        } label: {
                            if viewModel.isFetchingForecast {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("天気予報を取得")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(viewModel.isFetchingForecast)
                    }
                }

                if let forecastErrorMessage = viewModel.forecastErrorMessage {
                    Section {
                        Text(forecastErrorMessage)
                            .foregroundStyle(.red)
                    }
                }

                if !viewModel.dailyForecasts.isEmpty {
                    Section("3日間の天気予報") {
                        ForEach(viewModel.dailyForecasts) { forecast in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(forecast.date)
                                    .font(.headline)
                                LabeledContent("天気", value: forecast.condition.displayName)
                                LabeledContent(
                                    "気温",
                                    value: String(
                                        format: "最高 %.1f℃ / 最低 %.1f℃",
                                        forecast.maxTemperature,
                                        forecast.minTemperature
                                    )
                                )
                                LabeledContent(
                                    "降水確率",
                                    value: "\(forecast.precipitationProbability)%"
                                )
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("場所を探す")
        }
    }

    private func formatCoordinate(_ value: Double) -> String {
        String(format: "%.6f", value)
    }
}

#Preview {
    ContentView()
}
