//
//  HomeView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

// MARK: - HomeView (Root Screen)
//
// This is the "main page" of the app. It reads from the ViewModel and decides
// which state to display. Think of it like a Blade template that checks
// $status before rendering the right @section.
//
// Architecture note:
//   HomeView (smart)           — reads ViewModel, decides what to show
//     └── TopBarView           — always visible
//     └── stateContent         — switches between 4 states:
//           State 1: LocationPromptView  — no city selected yet
//           State 2: ProgressView        — fetching weather
//           State 3: weather UI          — data loaded
//           State 4: ErrorView           — fetch failed

struct HomeView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    // @State = local UI state, not shared outside this view.
    // Each boolean controls whether a specific sheet (modal) is open.
    @State private var showLocationSearch = false
    @State private var showForecast = false
    @State private var showSavedLocations = false

    var body: some View {
        ZStack {
            // Background gradient is always visible, regardless of the current state
            LinearGradient(
                colors: [Color(hex: "4A90D9"), Color(hex: "1C5EA8")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TopBarView(
                    cityName: viewModel.cityName,
                    isLoading: viewModel.isLoading,
                    onSearchTap: { showLocationSearch = true },
                    onSavedLocationsTap: { showSavedLocations = true }
                )

                stateContent
            }
        }
        // .sheet() = a modal that slides up from the bottom, like a bottom drawer.
        // isPresented: when the @State bool becomes true, the sheet opens.
        .sheet(isPresented: $showLocationSearch) {
            LocationView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showForecast) {
            ForecastView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showSavedLocations) {
            SavedLocationsView()
                .environmentObject(viewModel)
        }
    }

    // @ViewBuilder lets this computed property return different view types
    // based on conditions — like a PHP function that returns different HTML.
    @ViewBuilder
    var stateContent: some View {
        if viewModel.cityName == "Unknown" && !viewModel.isLoading {
            // State 1 — No location selected yet
            LocationPromptView(onSearchTap: { showLocationSearch = true })

        } else if viewModel.isLoading {
            // State 2 — Loading
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
            Spacer()

        } else if let weather = viewModel.weather {
            // State 3 — Data loaded, show the full weather UI
            // "if let" = safely unwrap an Optional. If weather is nil, skip this block.
            Spacer()
            WeatherHeroView(current: weather.current)
            Spacer()
            WeatherStatsView(
                windSpeed: weather.current.windSpeed,
                humidity: weather.current.humidity,
                rainProbability: weather.daily.precipitationProbabilityMax.first ?? 0
            )
            BottomPanelView(
                hourly: weather.hourly,
                currentTime: weather.current.time,
                onForecastTap: { showForecast = true }
            )

        } else if let error = viewModel.errorMessage {
            // State 4 — Something went wrong
            ErrorView(message: error, onRetry: { viewModel.retryLastLocation() })
        }
    }
}

// MARK: - TopBarView
//
// The bar at the top: search button, city name, and saved locations button.
// Receives data as plain parameters — no ViewModel dependency here.

struct TopBarView: View {
    let cityName: String
    let isLoading: Bool
    let onSearchTap: () -> Void
    let onSavedLocationsTap: () -> Void

    var body: some View {
        HStack {
            // Left: open city search
            CircleButtonView(icon: "magnifyingglass", action: onSearchTap)

            Spacer()

            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(cityName == "Unknown" ? "Select a city" : cityName)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)

                if cityName != "Unknown" {
                    // Status pill: orange while loading, green when live
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isLoading ? Color.orange : Color.green)
                            .frame(width: 6, height: 6)
                        Text(isLoading ? "Updating..." : "Live")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
            }

            Spacer()

            // Right: open saved locations page
            CircleButtonView(icon: "ellipsis", action: onSavedLocationsTap)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

// MARK: - WeatherHeroView
//
// The big icon + temperature + condition label in the center.
// Receives a CurrentWeather struct and renders it.

struct WeatherHeroView: View {
    let current: CurrentWeather

    var body: some View {
        VStack(spacing: 12) {
            // WeatherHelper.icon() maps the code integer to an SF Symbol name
            Image(systemName: WeatherHelper.icon(for: current.weathercode))
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 160)
                .foregroundStyle(.white, Color.yellow)
                .shadow(color: .yellow.opacity(0.6), radius: 20)

            HStack(alignment: .top, spacing: 0) {
                // Int(current.temperature) rounds 21.4 → 21
                Text("\(Int(current.temperature))")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                Text("°")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 16)
            }

            VStack(spacing: 4) {
                Text(WeatherHelper.label(for: current.weathercode))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                // WeatherHelper.formatDate() converts "2024-05-17T10:00" → "Monday, 17 May"
                Text(WeatherHelper.formatDate(current.time))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - WeatherStatsView
//
// The three stat pills: wind / humidity / rain probability.

struct WeatherStatsView: View {
    let windSpeed: Double
    let humidity: Double
    let rainProbability: Int   // 0–100 from daily.precipitationProbabilityMax[0]

    var body: some View {
        HStack(spacing: 0) {
            StatItemView(icon: "wind",           value: "\(Int(windSpeed)) km/h", label: "Wind")

            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1, height: 40)

            StatItemView(icon: "drop.fill",      value: "\(Int(humidity))%",      label: "Humidity")

            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1, height: 40)

            StatItemView(icon: "cloud.rain.fill", value: "\(rainProbability)%",   label: "Rain")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
    }
}

// MARK: - BottomPanelView
//
// The scrollable hourly forecast at the bottom. Maps real API data into cards.

struct BottomPanelView: View {
    let hourly: HourlyWeather
    let currentTime: String       // e.g. "2024-05-17T10:00" — the current weather snapshot time
    let onForecastTap: () -> Void

    // Build the list of hourly cards for the next 24 hours.
    // This is a computed property — it recalculates whenever the view redraws.
    // Think of it like a PHP getter method.
    var todayHours: [(time: String, temp: Int, icon: String)] {
        let count = min(24, hourly.time.count)
        return (0..<count).map { i in
            (
                time: WeatherHelper.formatHour(hourly.time[i]),
                temp: Int(hourly.temperature[i]),
                icon: WeatherHelper.icon(for: hourly.weathercode[i])
            )
        }
    }

    // The current time formatted as "HH:mm" so we can highlight the matching card
    var currentHour: String {
        WeatherHelper.formatHour(currentTime)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                Button(action: onForecastTap) {
                    HStack(spacing: 4) {
                        Text("7 days")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(todayHours, id: \.time) { item in
                        HourlyCardView(
                            time: item.time,
                            temp: item.temp,
                            icon: item.icon,
                            isSelected: item.time == currentHour
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
        .background(Color.black.opacity(0.25))
    }
}

// MARK: - LocationPromptView  (State 1)
//
// Shown when the user hasn't picked a city yet.

struct LocationPromptView: View {
    let onSearchTap: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.slash.fill")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.8))

            Text("No location selected")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Search for a city to see the weather")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: onSearchTap) {
                Label("Search Location", systemImage: "magnifyingglass")
                    .font(.headline)
                    .foregroundColor(Color(hex: "1C5EA8"))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(25)
            }

            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ErrorView  (State 4)
//
// Shown when the weather fetch fails.

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.8))

            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(Color(hex: "1C5EA8"))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(25)
            }

            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Reusable small components

struct CircleButtonView: View {
    let icon: String
    let action: () -> Void   // ← now accepts an action instead of always doing nothing

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

struct StatItemView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct HourlyCardView: View {
    let time: String
    let temp: Int
    let icon: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("\(temp)°")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .black : .white)

            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isSelected ? .black : .white.opacity(0.9))

            Text(time)
                .font(.caption)
                .foregroundColor(isSelected ? .black.opacity(0.7) : .white.opacity(0.7))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(isSelected ? Color.white : Color.white.opacity(0.15))
        .cornerRadius(20)
    }
}

// MARK: - Extensions

// Lets us write Color(hex: "4A90D9") anywhere in the app.
// Converts a hex string to RGB values SwiftUI understands.
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView()
        .environmentObject(WeatherViewModel())
}
