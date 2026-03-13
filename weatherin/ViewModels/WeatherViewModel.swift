//
//  WeatherViewModel.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var searchResults: [LocationResult] = []
    @Published var selectedLocation: LocationResult?
    @Published var cityName: String = "Unknown"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let weatherService = WeatherService()
    private let locationService = LocationService()
    private let geocodingService = GeocodingService()

    func loadWeatherFromGPS() {
        locationService.requestLocation()

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            await loadWeather(
                latitude: locationService.latitude,
                longitude: locationService.longitude,
                timezone: "auto",
                city: locationService.cityName
            )
        }
    }

    func selectLocation(_ location: LocationResult) {
        selectedLocation = location
        searchResults = []

        Task {
            await loadWeather(
                latitude: location.latitude,
                longitude: location.longitude,
                timezone: location.timezone,
                city: location.name
            )
        }
    }

    func searchCity(name: String) {
        guard name.count >= 3 else {
            searchResults = []
            return
        }

        Task {
            do {
                searchResults = try await geocodingService.searchCity(name: name)
            } catch {
                errorMessage = "Search failed: \(error.localizedDescription)"
            }
        }
    }

    private func loadWeather(latitude: Double, longitude: Double, timezone: String, city: String) async {
        isLoading = true
        errorMessage = nil

        do {
            weather = try await weatherService.fetchWeather(
                latitude: latitude,
                longitude: longitude,
                timezone: timezone
            )
            cityName = city
        } catch {
            errorMessage = "Failed to load weather: \(error.localizedDescription)"
        }

        isLoading = false
    }

}
