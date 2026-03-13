//
//  HomeView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

let dummyHourlyForecast: [(time: String, temp: Int, icon: String)] = [
    ("10:00", 23, "cloud.rain"),
    ("11:00", 21, "cloud.bolt"),
    ("12:00", 22, "cloud.rain"),
    ("13:00", 19, "wind"),
    ("14:00", 20, "cloud.sun"),
    ("15:00", 22, "sun.max")
]

struct HomeView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "4A90D9"), Color(hex: "1C5EA8")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBarView()
                
                Spacer()
                
                WeatherHeroView()
                
                Spacer()
                
                WeatherStatsView()
                
                BottomPanelView()
            }
        }
    }
}
 
struct TopBarView: View {
    var body: some View {
        HStack {
 
            CircleButtonView(icon: "square.grid.2x2")
 
            Spacer()
 
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text("Bogor")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
 
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Updating")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
            }
 
            Spacer()
 
            CircleButtonView(icon: "ellipsis")
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}
 
struct WeatherHeroView: View {
    var body: some View {
        VStack(spacing: 12) {
 
            Image(systemName: "cloud.bolt.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 160)
                .foregroundStyle(
                    .white,
                    Color.yellow
                )
                .shadow(color: .yellow.opacity(0.6), radius: 20)
 
            HStack(alignment: .top, spacing: 0) {
                Text("21")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                Text("°")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 16)
            }
 
            VStack(spacing: 4) {
                Text("Thunderstorm")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
 
                Text("Monday, 17 May")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

struct WeatherStatsView: View {
    var body: some View {
        HStack(spacing: 0) {
            StatItemView(icon: "wind", value: "13 km/h", label: "Wind")
            
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1, height: 40)
            
            StatItemView(icon: "drop.fill", value: "24%", label: "Humidity")
            
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1, height: 40)
            
            StatItemView(icon: "cloud.rain.fill", value: "87%", label: "Rain")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
    }
}
 
struct BottomPanelView: View {
    var body: some View {
        VStack(spacing: 16) {
 
            HStack {
                Text("Today")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
 
                Spacer()
 
                Button(action: {}) {
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
                    ForEach(dummyHourlyForecast, id: \.time) { item in
                        HourlyCardView(
                            time: item.time,
                            temp: item.temp,
                            icon: item.icon,
                            isSelected: item.time == "11:00"
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

struct CircleButtonView: View {
    let icon: String
 
    var body: some View {
        Button(action: {}) {
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
}
