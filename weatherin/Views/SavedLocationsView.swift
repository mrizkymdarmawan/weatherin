//
//  SavedLocationsView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

struct SavedLocationsView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            List {
                currentCitySection
                savedCitiesSection
            }
            .navigationTitle("My Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                LocationView()
                    .environmentObject(viewModel)
            }
        }
    }

    @ViewBuilder
    var currentCitySection: some View {
        if viewModel.cityName != "Unknown" {
            Section("Current City") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.cityName)
                            .font(.headline)
                        if let temp = viewModel.weather?.current.temperature {
                            Text("\(Int(temp))° — \(WeatherHelper.label(for: viewModel.weather?.current.weathercode ?? 0))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Button {
                        viewModel.saveCurrentLocation()
                    } label: {
                        Image(systemName: viewModel.isCurrentLocationSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.isCurrentLocationSaved)
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    var savedCitiesSection: some View {
        Section("Saved") {
            if viewModel.savedLocations.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Text("No saved cities yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tap + to search, or bookmark your current city above")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                ForEach(viewModel.savedLocations) { location in
                    Button {
                        viewModel.selectLocation(location)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(location.country) · \(location.timezone)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if location.id == viewModel.selectedLocation?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        viewModel.removeSavedLocation(viewModel.savedLocations[i])
                    }
                }
            }
        }
    }
}

#Preview {
    SavedLocationsView()
        .environmentObject(WeatherViewModel())
}
