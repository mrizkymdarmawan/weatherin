//
//  WeatherHelper.swift
//  weatherin
//
//  Think of this like a Laravel helper class — pure static functions, no state.
//  It converts raw API data (codes, ISO date strings) into human-readable display values.
//

import Foundation

struct WeatherHelper {

    // MARK: - Weather Code → Label

    // Open-Meteo returns an integer "weathercode" for the current condition.
    // This maps those codes to readable labels, like a PHP match expression.
    static func label(for code: Int) -> String {
        switch code {
        case 0:             return "Clear Sky"
        case 1, 2, 3:       return "Partly Cloudy"
        case 45, 48:        return "Foggy"
        case 51, 53, 55:    return "Drizzle"
        case 61, 63, 65:    return "Rain"
        case 71, 73, 75:    return "Snow"
        case 80, 81, 82:    return "Rain Showers"
        case 95:            return "Thunderstorm"
        case 96, 99:        return "Thunder & Hail"
        default:            return "Unknown"
        }
    }

    // MARK: - Weather Code → SF Symbol icon name

    // SF Symbols are Apple's built-in icon set (like FontAwesome but native).
    // We return the symbol name as a String — SwiftUI renders it with Image(systemName:).
    static func icon(for code: Int) -> String {
        switch code {
        case 0:             return "sun.max.fill"
        case 1, 2, 3:       return "cloud.sun.fill"
        case 45, 48:        return "cloud.fog.fill"
        case 51, 53, 55:    return "cloud.drizzle.fill"
        case 61, 63, 65:    return "cloud.rain.fill"
        case 71, 73, 75:    return "cloud.snow.fill"
        case 80, 81, 82:    return "cloud.heavyrain.fill"
        case 95:            return "cloud.bolt.fill"
        case 96, 99:        return "cloud.bolt.rain.fill"
        default:            return "cloud.fill"
        }
    }

    // MARK: - Date Formatting

    // "2024-05-17T10:00" → "Monday, 17 May"
    // DateFormatter is the Swift equivalent of PHP's date() or Carbon::parse()->format()
    static func formatDate(_ iso: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        guard let date = formatter.date(from: iso) else { return iso }
        formatter.dateFormat = "EEEE, d MMM"
        return formatter.string(from: date)
    }

    // "2024-05-17T10:00" → "10:00"
    // The last 5 characters of the ISO string are always "HH:mm", so we just slice it.
    // This avoids spinning up a DateFormatter for a trivial task — KISS in action.
    static func formatHour(_ iso: String) -> String {
        return String(iso.suffix(5))
    }

    // "2024-05-17" → "Mon, 17 May"  (used in the 7-day forecast list)
    static func formatDay(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
}
