//
//  WeatherService.swift
//  Weather
//
//  Networking layer for OpenWeatherMap API.
//

import Foundation

// MARK: - Protocol
protocol WeatherServiceProtocol {
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeatherResponse
    func fetchForecast(for city: String) async throws -> ForecastResponse
}

// MARK: - Errors
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case invalidAPIKey
    case noInternetConnection
    case apiLimitReached
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .serverError(let code):
            if code == 401 {
                return "Invalid API key. Please check your API key."
            } else if code == 429 {
                return "API limit reached. Please try again later."
            } else if code == 404 {
                return "City not found."
            }
            return "Server error (\(code))."
        case .invalidAPIKey:
            return "Invalid API key."
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        case .apiLimitReached:
            return "API limit reached. Please try again later."
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}

// MARK: - Implementation
final class WeatherService: WeatherServiceProtocol {
    
    // MARK: - Singleton
    static let shared = WeatherService()
    
    private let apiKey = Secrets.apiKey
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let session: URLSession
    
    // MARK: - Private Initializer (Singleton Pattern)
    private init(session: URLSession? = nil) {
        // Use optimized URLSession configuration for better performance
        if let session = session {
            self.session = session
        } else {
            // Use shared configuration for faster initialization
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 8
            configuration.timeoutIntervalForResource = 20
            configuration.requestCachePolicy = .returnCacheDataElseLoad // Use cache when available
            configuration.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
            configuration.httpMaximumConnectionsPerHost = 4
            configuration.httpShouldUsePipelining = true
            configuration.waitsForConnectivity = false // Don't wait for connectivity
            self.session = URLSession(configuration: configuration)
        }
    }
    
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeatherResponse {
        let urlString = "\(baseURL)/weather?q=\(city)&appid=\(apiKey)&units=metric"
        return try await request(urlString)
    }
    
    func fetchForecast(for city: String) async throws -> ForecastResponse {
        let urlString = "\(baseURL)/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        return try await request(urlString)
    }
    
    // MARK: - Private
    
    private func request<T: Decodable>(_ urlString: String) async throws -> T {
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let http = response as? HTTPURLResponse else {
                throw WeatherError.invalidResponse
            }
            
            // Handle specific error codes
            if http.statusCode == 401 {
                throw WeatherError.invalidAPIKey
            } else if http.statusCode == 429 {
                throw WeatherError.apiLimitReached
            } else if !(200...299).contains(http.statusCode) {
                throw WeatherError.serverError(http.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw WeatherError.decodingError(error)
            }
        } catch let error as WeatherError {
            throw error
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                throw WeatherError.noInternetConnection
            }
            throw WeatherError.invalidResponse
        } catch {
            throw WeatherError.invalidResponse
        }
    }
}
