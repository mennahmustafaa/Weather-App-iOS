//
//  WeatherAPIModels.swift
//  Weather
//
//  Codable models for OpenWeatherMap API responses.
//

import Foundation

// MARK: - Current Weather Response
struct CurrentWeatherResponse: Codable {
    let name: String
    let main: MainData
    let weather: [WeatherCondition]
    let wind: WindData?
    let visibility: Int?
    let dt: TimeInterval
    
    struct MainData: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case humidity
        }
    }
    
    struct WeatherCondition: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct WindData: Codable {
        let speed: Double
    }
}

// MARK: - 5-Day / 3-Hour Forecast Response
struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
    
    struct ForecastItem: Codable {
        let dt: TimeInterval
        let main: CurrentWeatherResponse.MainData
        let weather: [CurrentWeatherResponse.WeatherCondition]
        let pop: Double? // Probability of precipitation (0–1)
    }
    
    struct City: Codable {
        let name: String
        let country: String?
    }
}

// MARK: - Condition Code → Weather Enum Mapping
extension CurrentWeatherResponse.WeatherCondition {
    /// Maps OpenWeatherMap condition codes to the app's Weather enum.
    /// OpenWeatherMap condition codes: https://openweathermap.org/weather-conditions
    var mapped: Weather {
        switch id {
        case 200...232: return .stormy       // Thunderstorm (2xx)
        case 300...321: return .rainy        // Drizzle (3xx)
        case 500...504: return .rainy        // Light/Moderate Rain (5xx)
        case 511: return .rainy              // Freezing rain
        case 520...531: return .stormy       // Heavy rain/Shower rain (5xx)
        case 600...622: return .cloudy       // Snow (6xx) - using cloudy as closest match
        case 701...721: return .windy        // Mist, Smoke, Haze, Fog (7xx)
        case 731, 761, 762: return .windy     // Dust, Sand, Ash (7xx)
        case 771: return .windy              // Squalls
        case 781: return .tornado            // Tornado
        case 800: return .sunny              // Clear sky - use sunny for better icon
        case 801: return .clear              // Few clouds (11-25%)
        case 802: return .cloudy             // Scattered clouds (25-50%)
        case 803, 804: return .cloudy        // Broken/Overcast clouds (51-100%)
        default: return .clear
        }
    }
}
