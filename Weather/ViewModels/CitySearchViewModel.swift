//
//  CitySearchViewModel.swift
//  Weather
//
//  ViewModel for searching and managing multiple cities.
//

import Foundation

@MainActor
final class CitySearchViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var searchText: String = ""
    @Published var searchResults: [Forecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service: WeatherServiceProtocol
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Init
    init(service: WeatherServiceProtocol = WeatherService.shared) {
        self.service = service
    }
    
    // MARK: - Search Cities
    func searchCity(_ cityName: String) {
        // Cancel previous search task
        searchTask?.cancel()
        
        let trimmedCity = cityName.trimmingCharacters(in: .whitespaces)
        guard !trimmedCity.isEmpty else {
            searchResults = []
            isLoading = false
            return
        }
        
        // Only search if city name has at least 2 characters
        guard trimmedCity.count >= 2 else {
            return
        }
        
        // Debounce search - wait 0.5 seconds before searching
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            guard !Task.isCancelled else { return }
            
            await performSearch(cityName)
        }
    }
    
    private func performSearch(_ cityName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch current weather for the searched city
            let current = try await service.fetchCurrentWeather(for: cityName)
            let forecast = try await service.fetchForecast(for: cityName)
            
            // Build location string
            let countryName = forecast.city.country ?? ""
            let locationString = countryName.isEmpty ? current.name : "\(current.name), \(countryName)"
            
            // Get probability from forecast (use first forecast item's pop value)
            let probability = Int((forecast.list.first?.pop ?? 0) * 100)
            
            // Create Forecast model from API response with correct weather mapping
            let weatherCondition = current.weather.first?.mapped ?? .clear
            let forecastModel = Forecast(
                date: Date(timeIntervalSince1970: current.dt),
                weather: weatherCondition,
                probability: probability,
                temperature: Int(current.main.temp.rounded()),
                high: Int(current.main.tempMax.rounded()),
                low: Int(current.main.tempMin.rounded()),
                location: locationString
            )
            
            // Replace results with the new search result (show most recent search)
            searchResults = [forecastModel]
            
        } catch let error as WeatherError {
            if case .serverError(let code) = error, code == 404 {
                // City not found - don't show error, just don't add to results
                errorMessage = nil
            } else {
                errorMessage = error.errorDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Clear Search
    func clearSearch() {
        searchText = ""
        searchResults = []
        searchTask?.cancel()
    }
    
    // MARK: - Remove City
    func removeCity(_ forecast: Forecast) {
        searchResults.removeAll { $0.id == forecast.id }
    }
}
