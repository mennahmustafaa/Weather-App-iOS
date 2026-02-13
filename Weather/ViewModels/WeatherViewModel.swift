//
//  WeatherViewModel.swift
//  Weather
//
//  ViewModel managing weather data from OpenWeatherMap API.
//

import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var cityName: String = "Cairo"
    @Published var temperature: Int = 0
    @Published var high: Int = 0
    @Published var low: Int = 0
    @Published var conditionText: String = "Loading..."
    @Published var hourlyForecasts: [Forecast] = []
    @Published var dailyForecasts: [Forecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service: WeatherServiceProtocol
    private var city: String
    
    // MARK: - Init
    init(service: WeatherServiceProtocol = WeatherService.shared, city: String = "Cairo,EG") {
        self.service = service
        self.city = city
    }
    
    // MARK: - Update City
    func updateCity(_ newCity: String) {
        city = newCity
    }
    
    // MARK: - Fetch Weather
    func fetchWeather() async {
        errorMessage = nil
        
        do {
            // Fetch current weather first (faster, smaller response)
            async let currentTask = service.fetchCurrentWeather(for: city)
            async let forecastTask = service.fetchForecast(for: city)
            
            // Update UI immediately when current weather arrives
            let current = try await currentTask
            
            // Update current weather immediately for faster UI response
            cityName = current.name
            temperature = Int(current.main.temp.rounded())
            conditionText = current.weather.first?.description.capitalized ?? "Clear"
            high = Int(current.main.tempMax.rounded())
            low = Int(current.main.tempMin.rounded())
            
            // Wait for forecast and update with more accurate data
            let forecast = try await forecastTask
            
            // Use forecast data for more accurate high/low temperatures
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let todayForecasts = forecast.list.filter { item in
                let itemDate = Date(timeIntervalSince1970: item.dt)
                return calendar.isDate(itemDate, inSameDayAs: today)
            }
            
            if !todayForecasts.isEmpty {
                // Calculate actual min/max from today's forecasts
                let maxTemps = todayForecasts.map { $0.main.tempMax }
                let minTemps = todayForecasts.map { $0.main.tempMin }
                
                // Use the maximum of forecast max temps and current max, minimum of forecast min temps and current min
                high = Int(max(maxTemps.max() ?? current.main.tempMax, current.main.tempMax).rounded())
                low = Int(min(minTemps.min() ?? current.main.tempMin, current.main.tempMin).rounded())
            }
            
            // Build location string with country
            let countryName = forecast.city.country ?? "Egypt"
            let locationString = "\(current.name), \(countryName)"
            
            // Build hourly forecasts (next 6 entries from 3-hour forecast)
            let hourlyItems = Array(forecast.list.prefix(6))
            hourlyForecasts = hourlyItems.map { item in
                Forecast(
                    date: Date(timeIntervalSince1970: item.dt),
                    weather: item.weather.first?.mapped ?? .clear,
                    probability: Int((item.pop ?? 0) * 100),
                    temperature: Int(item.main.temp.rounded()),
                    high: Int(item.main.tempMax.rounded()),
                    low: Int(item.main.tempMin.rounded()),
                    location: locationString
                )
            }
            
            // Build daily forecasts (pick one entry per day from the forecast list)
            dailyForecasts = buildDailyForecasts(from: forecast, location: locationString)
            
        } catch let error as WeatherError {
            errorMessage = error.errorDescription ?? error.localizedDescription
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Private Helpers
    
    /// Groups 3-hour intervals by day and picks one representative entry per day.
    private func buildDailyForecasts(from response: ForecastResponse, location: String) -> [Forecast] {
        let calendar = Calendar.current
        var dailyMap: [DateComponents: ForecastResponse.ForecastItem] = [:]
        var order: [DateComponents] = []
        
        for item in response.list {
            let date = Date(timeIntervalSince1970: item.dt)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            
            if dailyMap[components] == nil {
                dailyMap[components] = item
                order.append(components)
            }
        }
        
        return Array(order.prefix(6)).compactMap { key in
            guard let item = dailyMap[key] else { return nil }
            return Forecast(
                date: Date(timeIntervalSince1970: item.dt),
                weather: item.weather.first?.mapped ?? .clear,
                probability: Int((item.pop ?? 0) * 100),
                temperature: Int(item.main.temp.rounded()),
                high: Int(item.main.tempMax.rounded()),
                low: Int(item.main.tempMin.rounded()),
                location: location
            )
        }
    }
}
