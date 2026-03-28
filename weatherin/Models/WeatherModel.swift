//
//  WeatherModel.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

// Codable = Swift's way of auto-decoding JSON into structs.
// Think of it like Laravel's json_decode() but type-safe and automatic.
// The CodingKeys enum handles snake_case → camelCase renaming.

import Foundation

struct WeatherResponse: Codable {
    var current: CurrentWeather
    var hourly: HourlyWeather
    var daily: DailyWeather
}

struct CurrentWeather: Codable {
    var time: String
    var temperature: Double
    var windSpeed: Double
    var humidity: Double
    var weathercode: Int           // ← added: condition code (0 = clear, 95 = thunderstorm, etc.)

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case windSpeed   = "wind_speed_10m"
        case humidity    = "relative_humidity_2m"
        case weathercode
    }
}

struct HourlyWeather: Codable {
    var time: [String]
    var temperature: [Double]
    var windSpeed: [Double]
    var humidity: [Double]
    var weathercode: [Int]         // ← added: one code per hour for icon display

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case windSpeed   = "wind_speed_10m"
        case humidity    = "relative_humidity_2m"
        case weathercode
    }
}

struct DailyWeather: Codable {
    var time: [String]
    var maxTemperature: [Double]
    var minTemperature: [Double]
    var weatherCode: [Int]
    var precipitationProbabilityMax: [Int]   // ← added: rain chance (0–100%) per day

    enum CodingKeys: String, CodingKey {
        case time
        case maxTemperature              = "temperature_2m_max"
        case minTemperature              = "temperature_2m_min"
        case weatherCode                 = "weathercode"
        case precipitationProbabilityMax = "precipitation_probability_max"
    }
}

struct GeocodingResponse: Codable {
    // Optional because Open-Meteo omits the "results" key entirely when nothing is found.
    // Without Optional here, decoding would crash on an empty search result.
    var results: [LocationResult]?
}

struct LocationResult: Codable, Identifiable {
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var country: String
    var timezone: String

    var displayName: String {
        return "\(name), \(country)"
    }
}
