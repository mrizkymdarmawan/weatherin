//
//  HomeView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - City Name
            Text(viewModel.cityName)
                .font(.title)

            // MARK: - Loading State
            if viewModel.isLoading {
                ProgressView("Loading weather...")
            }

            // MARK: - Error State
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            // MARK: - Current Weather
            if let weather = viewModel.weather {
                VStack(spacing: 8) {
                    Text("Temperature: \(weather.current.temperature, specifier: "%.1f")°C")
                    Text("Wind: \(weather.current.windSpeed, specifier: "%.1f") km/h")
                    Text("Humidity: \(weather.current.humidity, specifier: "%.0f")%")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }

            // MARK: - Search Bar
            HStack {
                TextField("Search city...", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Button("Search") {
                    viewModel.searchCity(name: searchText)
                }
            }
            .padding(.horizontal)

            // MARK: - Search Results
            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(viewModel.searchResults) { location in
                        Button(location.displayName) {
                            viewModel.selectLocation(location)
                            searchText = ""
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
                .padding(.horizontal)
            }

            // MARK: - GPS Button
            Button("Use My Location") {
                viewModel.loadWeatherFromGPS()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(.top)
        .onAppear {
            // Load weather automatically when screen opens
            viewModel.loadWeatherFromGPS()
        }
    }
}

#Preview {
    HomeView()
}
