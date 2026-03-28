//
//  LocationView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

// MARK: - LocationView
//
// The city search screen. Opens as a sheet (modal) from HomeView.
//
// Flow:
//   1. User types a city name (>= 3 characters)
//   2. viewModel.searchCity() fires an API call to the geocoding service
//   3. Results appear as a list
//   4. Tapping a result calls viewModel.selectLocation() → fetches weather → sheet closes

struct LocationView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss   // dismiss = close this sheet, like history.back() in JS

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                resultContent
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Search Field

    var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search city...", text: $searchText)
                .autocorrectionDisabled()
                // onChange fires every time searchText changes — like a JavaScript input event
                .onChange(of: searchText) {
                    viewModel.searchCity(name: searchText)
                }

            // Clear button — only shown when there is text
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    viewModel.searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }

    // MARK: - Result Content
    //
    // Shows different content depending on what state the search is in.
    // @ViewBuilder lets us return different views from a conditional block.

    @ViewBuilder
    var resultContent: some View {
        if searchText.count < 3 {
            // Hint: user hasn't typed enough yet
            emptyState(
                icon: "magnifyingglass",
                message: "Type at least 3 characters to search"
            )
        } else if viewModel.searchResults.isEmpty {
            // API returned no results
            emptyState(
                icon: "location.slash",
                message: "No results for \"\(searchText)\""
            )
        } else {
            // Show results list
            List(viewModel.searchResults) { location in
                Button {
                    viewModel.selectLocation(location)
                    dismiss()   // close the sheet after selection
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack(spacing: 4) {
                            Text(location.country)
                            Text("·")
                            Text(location.timezone)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
        }
    }

    // MARK: - Empty State Helper
    //
    // Reusable centered message with an icon.
    // A private function here avoids creating a whole new struct for something so simple.

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LocationView()
        .environmentObject(WeatherViewModel())
}
