//
//  WeatherView.swift
//  Weather
//
//  Created by Dara To on 2022-06-23.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var searchViewModel = CitySearchViewModel()
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    var searchResults: [Forecast] {
        if searchText.isEmpty {
            return Forecast.cities
        } else {
            // First filter default cities
            let filteredCities = Forecast.cities.filter { $0.location.localizedCaseInsensitiveContains(searchText) }
            
            // If we have API search results, combine them (avoid duplicates)
            var results = filteredCities
            for apiResult in searchViewModel.searchResults {
                if !results.contains(where: { $0.location == apiResult.location }) {
                    results.append(apiResult)
                }
            }
            
            return results
        }
    }
    
    var body: some View {
        ZStack {
            // MARK: Background
            Color.background
                .ignoresSafeArea()
            
            // MARK: Weather Widgets
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(searchResults) { forecast in
                        Button {
                            selectCity(forecast.location)
                        } label: {
                            WeatherWidget(forecast: forecast)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Loading indicator
                    if searchViewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                    
                    // Error message
                    if let errorMessage = searchViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                EmptyView()
                    .frame(height: 110)
            }
        }
        .overlay {
            // MARK: Navigation Bar
            NavigationBar(searchText: $searchText)
        }
        .navigationBarHidden(true)
        .onChange(of: searchText) { newValue in
            searchViewModel.searchText = newValue
            if !newValue.isEmpty && newValue.count >= 2 {
                searchViewModel.searchCity(newValue)
            } else {
                searchViewModel.clearSearch()
            }
        }
    }
    
    // MARK: - Select City
    private func selectCity(_ cityLocation: String) {
        // Use the location string directly - OpenWeatherMap API accepts "City, Country" format
        // The API will handle the parsing
        NotificationCenter.default.post(name: NSNotification.Name("CitySelected"), object: cityLocation)
        dismiss()
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeatherView()
                .preferredColorScheme(.dark)
        }
    }
}
