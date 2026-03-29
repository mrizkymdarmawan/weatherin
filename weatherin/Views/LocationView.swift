//
//  LocationView.swift
//  weatherin
//
//  Created by Muhammad Rizky Maulana Darmawan on 13/03/26.
//

import SwiftUI

struct LocationView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss

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

    var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search city...", text: $searchText)
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    viewModel.searchCity(name: searchText)
                }

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

    @ViewBuilder
    var resultContent: some View {
        if searchText.count < 3 {
            emptyState(
                icon: "magnifyingglass",
                message: "Type at least 3 characters to search"
            )
        } else if viewModel.searchResults.isEmpty {
            emptyState(
                icon: "location.slash",
                message: "No results for \"\(searchText)\""
            )
        } else {
            List(viewModel.searchResults) { location in
                Button {
                    viewModel.selectLocation(location)
                    dismiss()
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
