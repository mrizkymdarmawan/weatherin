//
//  GeocodingService.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import Foundation

class GeocodingService {

    private let baseUrl = "https://geocoding-api.open-meteo.com/v1/search"

    func searchCity(name: String) async throws -> [LocationResult] {
        
        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        
        let params = [
            "name=\(query)",
            "count=10",
            "language=en",
            "format=json"
        ].joined(separator: "&")
        
        guard let url = URL(string: "\(baseUrl)?\(params)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results
    }
}
