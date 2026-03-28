//
//  SavedLocationsView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

// MARK: - SavedLocationsView
//
// A dedicated page for managing your saved cities.
// Opens as a sheet when the user taps the three-dot button.
//
// What you can do here:
//   - See the current city and save it with one tap
//   - Switch to any saved city (tap a row)
//   - Delete a saved city (swipe left on a row)
//   - Add a new city via the + button (opens LocationView)

struct SavedLocationsView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss

    // Controls whether the city search sheet is open
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
                // Done button on the left — closes this sheet
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                // + button on the right — opens city search
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // Presenting LocationView as a sheet inside this sheet.
            // iOS 16.4+ supports sheets inside sheets — we're on iOS 26 so this is fine.
            .sheet(isPresented: $showSearch) {
                LocationView()
                    .environmentObject(viewModel)
            }
        }
    }

    // MARK: - Current City Section
    //
    // Shows the city currently displayed on HomeView.
    // The bookmark button saves it to the list.

    @ViewBuilder
    var currentCitySection: some View {
        if viewModel.cityName != "Unknown" {
            Section("Current City") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.cityName)
                            .font(.headline)
                        // Show current temperature as a subtitle
                        if let temp = viewModel.weather?.current.temperature {
                            Text("\(Int(temp))° — \(WeatherHelper.label(for: viewModel.weather?.current.weathercode ?? 0))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // Bookmark button — saves the current city
                    // disabled when already saved so you can't add duplicates
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

    // MARK: - Saved Cities Section

    @ViewBuilder
    var savedCitiesSection: some View {
        Section("Saved") {
            if viewModel.savedLocations.isEmpty {
                // Empty state — shown when no cities are saved yet
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
                // List of saved cities — tap to switch, swipe left to delete
                ForEach(viewModel.savedLocations) { location in
                    Button {
                        viewModel.selectLocation(location)
                        dismiss()   // go back to HomeView after switching
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
                            // Highlight the city currently showing on HomeView
                            if location.id == viewModel.selectedLocation?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                // onDelete = swipe-left-to-delete gesture, built into SwiftUI List
                // IndexSet tells us which rows the user swiped — like an array of positions
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
