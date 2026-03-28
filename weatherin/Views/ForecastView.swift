//
//  ForecastView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

// MARK: - ForecastView
//
// The 7-day forecast screen. Opens as a sheet from the "7 days >" button in HomeView.
//
// It reads weather.daily which has arrays of 7 items:
//   daily.time[0]           → today's date string
//   daily.maxTemperature[0] → today's high
//   daily.minTemperature[0] → today's low
//   daily.weatherCode[0]    → today's condition code
// ...and so on up to index 6 (7 days total).

struct ForecastView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Same background as HomeView for visual consistency
                LinearGradient(
                    colors: [Color(hex: "4A90D9"), Color(hex: "1C5EA8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Only render the list if weather data is available.
                // In practice this view is only reachable when weather is loaded,
                // but "if let" keeps the code safe — no force-unwrap crashes.
                if let weather = viewModel.weather {
                    ScrollView {
                        VStack(spacing: 12) {
                            // daily.time.indices → [0, 1, 2, 3, 4, 5, 6]
                            // We use indices so we can access parallel arrays by the same index.
                            ForEach(weather.daily.time.indices, id: \.self) { i in
                                DailyRowView(
                                    day: WeatherHelper.formatDay(weather.daily.time[i]),
                                    icon: WeatherHelper.icon(for: weather.daily.weatherCode[i]),
                                    label: WeatherHelper.label(for: weather.daily.weatherCode[i]),
                                    maxTemp: Int(weather.daily.maxTemperature[i]),
                                    minTemp: Int(weather.daily.minTemperature[i]),
                                    isToday: i == 0   // first entry is always today
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(viewModel.cityName)
            .navigationBarTitleDisplayMode(.inline)
            // Make the navigation bar match the blue gradient
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(hex: "1C5EA8"), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - DailyRowView
//
// A single row in the forecast list.
// Receives plain values — no ViewModel dependency here.

struct DailyRowView: View {
    let day: String
    let icon: String
    let label: String
    let maxTemp: Int
    let minTemp: Int
    let isToday: Bool

    var body: some View {
        HStack {
            // Day column — slightly wider to fit "Wednesday" etc.
            Text(isToday ? "Today" : day)
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(.white)
                .frame(width: 110, alignment: .leading)

            // Weather icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 30)

            // Condition label
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            // Temperature range: max in bright white, min in dimmed white
            HStack(spacing: 8) {
                Text("\(maxTemp)°")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("\(minTemp)°")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white.opacity(isToday ? 0.25 : 0.12))
        .cornerRadius(12)
    }
}

#Preview {
    ForecastView()
        .environmentObject(WeatherViewModel())
}
