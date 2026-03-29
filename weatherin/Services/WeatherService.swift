//
//  WeatherService.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import Foundation

class WeatherService {
    private let baseUrl = "https://api.open-meteo.com/v1/forecast"

    func fetchWeather(latitude: Double, longitude: Double, timezone: String) async throws -> WeatherResponse {

        let params = [
            "latitude=\(latitude)",
            "longitude=\(longitude)",
            "timezone=\(timezone)",
            "current=temperature_2m,wind_speed_10m,relative_humidity_2m,weathercode",
            "hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weathercode",
            "daily=temperature_2m_max,temperature_2m_min,weathercode,precipitation_probability_max",
            "forecast_days=7"
        ].joined(separator: "&")

        guard let url = URL(string: "\(baseUrl)?\(params)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
