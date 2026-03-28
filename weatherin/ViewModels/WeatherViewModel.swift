//
//  WeatherViewModel.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

// ViewModel = the brain between the View and the Service layer.
// In Laravel terms: this is your Controller.
// @MainActor ensures all @Published property updates happen on the main thread (UI thread).

import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {

    // MARK: - Published Properties
    //
    // @Published = any View watching this ViewModel will automatically re-render
    // when these values change. Think of it like Vue.js reactive data.

    @Published var weather: WeatherResponse?
    @Published var searchResults: [LocationResult] = []
    @Published var selectedLocation: LocationResult?
    @Published var cityName: String = "Unknown"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Saved locations — persisted in UserDefaults (like Laravel's cache)
    @Published var savedLocations: [LocationResult] = []

    // MARK: - Services

    private let weatherService   = WeatherService()
    private let locationService  = LocationService()
    private let geocodingService = GeocodingService()

    // MARK: - Init

    init() {
        // Load saved locations from UserDefaults when the app starts.
        // UserDefaults is key-value storage on device — like Laravel's cache()->get()
        loadSavedLocations()
    }

    // MARK: - Saved Locations

    // Check if the currently displayed city is already in the saved list
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

    // Read saved locations from UserDefaults.
    // Data is stored as JSON — JSONDecoder turns it back into [LocationResult].
    private func loadSavedLocations() {
        guard let data = UserDefaults.standard.data(forKey: "savedLocations"),
              let decoded = try? JSONDecoder().decode([LocationResult].self, from: data)
        else { return }
        savedLocations = decoded
    }

    // Write saved locations to UserDefaults.
    // JSONEncoder turns [LocationResult] into Data (raw bytes), then we store that.
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
    //
    // Called by ErrorView's "Try Again" button.
    // Re-runs the fetch for whatever city was selected before the error.

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
