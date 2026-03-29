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

    // MARK: - Published Properties

    @Published var weather: WeatherResponse?
    @Published var searchResults: [LocationResult] = []
    @Published var selectedLocation: LocationResult?
    @Published var cityName: String = "Unknown"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var savedLocations: [LocationResult] = []

    // MARK: - Services

    private let weatherService   = WeatherService()
    private let locationService  = LocationService()
    private let geocodingService = GeocodingService()

    // MARK: - Init

    init() {
        loadSavedLocations()
    }

    // MARK: - Saved Locations

    var isCurrentLocationSaved: Bool {
        guard let location = selectedLocation else { return false }
        return savedLocations.contains(where: { $0.id == location.id })
    }

    func saveCurrentLocation() {
        guard let location = selectedLocation, !isCurrentLocationSaved else { return }
        savedLocations.append(location)
        persistSavedLocations()
    }

    func removeSavedLocation(_ location: LocationResult) {
        savedLocations.removeAll { $0.id == location.id }
        persistSavedLocations()
    }

    private func loadSavedLocations() {
        guard let data = UserDefaults.standard.data(forKey: "savedLocations"),
              let decoded = try? JSONDecoder().decode([LocationResult].self, from: data)
        else { return }
        savedLocations = decoded
    }

    private func persistSavedLocations() {
        if let encoded = try? JSONEncoder().encode(savedLocations) {
            UserDefaults.standard.set(encoded, forKey: "savedLocations")
        }
    }

    // MARK: - Load Weather by GPS

    func loadWeatherFromGPS() {
        locationService.requestLocation()

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await loadWeather(
                latitude:  locationService.latitude,
                longitude: locationService.longitude,
                timezone:  "auto",
                city:      locationService.cityName
            )
        }
    }

    // MARK: - Retry last known location

    func retryLastLocation() {
        guard let location = selectedLocation else {
            loadWeatherFromGPS()
            return
        }
        selectLocation(location)
    }

    // MARK: - Load Weather by Selected Location

    func selectLocation(_ location: LocationResult) {
        selectedLocation = location
        searchResults = []

        Task {
            await loadWeather(
                latitude:  location.latitude,
                longitude: location.longitude,
                timezone:  location.timezone,
                city:      location.name
            )
        }
    }

    // MARK: - Search Cities

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

    // MARK: - Private: fetch weather and update state

    private func loadWeather(latitude: Double, longitude: Double, timezone: String, city: String) async {
        isLoading    = true
        errorMessage = nil

        do {
            weather  = try await weatherService.fetchWeather(
                latitude:  latitude,
                longitude: longitude,
                timezone:  timezone
            )
            cityName = city
        } catch {
            errorMessage = "Failed to load weather: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
