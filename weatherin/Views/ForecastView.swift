//
//  ForecastView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "4A90D9"), Color(hex: "1C5EA8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                if let weather = viewModel.weather {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(weather.daily.time.indices, id: \.self) { i in
                                DailyRowView(
                                    day: WeatherHelper.formatDay(weather.daily.time[i]),
                                    icon: WeatherHelper.icon(for: weather.daily.weatherCode[i]),
                                    label: WeatherHelper.label(for: weather.daily.weatherCode[i]),
                                    maxTemp: Int(weather.daily.maxTemperature[i]),
                                    minTemp: Int(weather.daily.minTemperature[i]),
                                    isToday: i == 0
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(viewModel.cityName)
            .navigationBarTitleDisplayMode(.inline)
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

struct DailyRowView: View {
    let day: String
    let icon: String
    let label: String
    let maxTemp: Int
    let minTemp: Int
    let isToday: Bool

    var body: some View {
        HStack {
            Text(isToday ? "Today" : day)
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(.white)
                .frame(width: 110, alignment: .leading)

            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 30)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

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
