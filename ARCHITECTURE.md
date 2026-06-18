# Architecture Documentation
## SOLID Principles & Design Patterns

This document outlines the SOLID principles and design patterns implemented in the Weather App project.

---

## Table of Contents
1. [SOLID Principles](#solid-principles)
2. [Design Patterns](#design-patterns)
3. [Project Structure](#project-structure)
4. [Code Examples](#code-examples)

---

## SOLID Principles

### 1. Single Responsibility Principle (SRP)
**Principle**: A class should have only one reason to change.

#### Implementation in Project:

**WeatherService.swift** (`Weather/Services/WeatherService.swift`)
- **Responsibility**: Handles all network communication with OpenWeatherMap API
- **Single Purpose**: Fetching weather data from external API
- **Location**: Lines 54-114

```swift
final class WeatherService: WeatherServiceProtocol {
    // Only responsible for API communication
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeatherResponse
    func fetchForecast(for city: String) async throws -> ForecastResponse
}
```

**WeatherViewModel.swift** (`Weather/ViewModels/WeatherViewModel.swift`)
- **Responsibility**: Manages UI state and business logic
- **Single Purpose**: Transform API data into UI-ready format
- **Location**: Lines 11-112

```swift
@MainActor
final class WeatherViewModel: ObservableObject {
    // Only responsible for view state management
    @Published var cityName: String
    @Published var temperature: Int
    // ...
}
```

**WeatherAPIModels.swift** (`Weather/Models/WeatherAPIModels.swift`)
- **Responsibility**: Data models for API responses
- **Single Purpose**: Define structure of API data
- **Location**: Lines 11-88

---

### 2. Open/Closed Principle (OCP)
**Principle**: Software entities should be open for extension but closed for modification.

#### Implementation in Project:

**Protocol-Oriented Design** (`Weather/Services/WeatherService.swift`)
- **Location**: Lines 11-14
- **How it works**: `WeatherServiceProtocol` allows extension without modifying existing code
- **Example**: You can create a `MockWeatherService` for testing without changing `WeatherService`

```swift
protocol WeatherServiceProtocol {
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeatherResponse
    func fetchForecast(for city: String) async throws -> ForecastResponse
}

// Can extend with new implementations without modifying existing code
class MockWeatherService: WeatherServiceProtocol {
    // Test implementation
}
```

**Extension Pattern** (`Weather/Models/WeatherAPIModels.swift`)
- **Location**: Lines 65-88
- **How it works**: Weather condition mapping is added via extension, not by modifying the original struct

```swift
extension CurrentWeatherResponse.WeatherCondition {
    var mapped: Weather {
        // Mapping logic added via extension
    }
}
```

---

### 3. Liskov Substitution Principle (LSP)
**Principle**: Objects of a superclass should be replaceable with objects of its subclasses without breaking the application.

#### Implementation in Project:

**Protocol Conformance** (`Weather/Services/WeatherService.swift`)
- **Location**: Lines 54-114
- **How it works**: Any class conforming to `WeatherServiceProtocol` can replace `WeatherService` in `WeatherViewModel`
- **Example**: `WeatherViewModel` accepts `WeatherServiceProtocol`, allowing any conforming implementation

```swift
// WeatherViewModel.swift, Line 28
init(service: WeatherServiceProtocol = WeatherService(), city: String = "Cairo,EG") {
    self.service = service  // Can accept any WeatherServiceProtocol implementation
}
```

---

### 4. Interface Segregation Principle (ISP)
**Principle**: Clients should not be forced to depend on interfaces they do not use.

#### Implementation in Project:

**Focused Protocol** (`Weather/Services/WeatherService.swift`)
- **Location**: Lines 11-14
- **How it works**: `WeatherServiceProtocol` contains only methods needed for weather data fetching
- **No unnecessary methods**: Protocol is minimal and focused

```swift
protocol WeatherServiceProtocol {
    // Only essential methods, no bloat
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeatherResponse
    func fetchForecast(for city: String) async throws -> ForecastResponse
}
```

**Separate Error Types** (`Weather/Services/WeatherService.swift`)
- **Location**: Lines 17-51
- **How it works**: `WeatherError` enum is separate and focused on weather-specific errors

---

### 5. Dependency Inversion Principle (DIP)
**Principle**: High-level modules should not depend on low-level modules. Both should depend on abstractions.

#### Implementation in Project:

**Dependency Injection via Protocol** (`Weather/ViewModels/WeatherViewModel.swift`)
- **Location**: Lines 24, 28-31
- **How it works**: `WeatherViewModel` depends on `WeatherServiceProtocol` (abstraction), not `WeatherService` (concrete class)

```swift
// High-level module (ViewModel) depends on abstraction (Protocol)
private let service: WeatherServiceProtocol  // Abstraction, not concrete class

init(service: WeatherServiceProtocol = WeatherService(), city: String = "Cairo,EG") {
    self.service = service  // Dependency injection
}
```

**Benefits**:
- Easy to test (can inject mock service)
- Easy to swap implementations
- Loose coupling between layers

---

## Design Patterns

### 1. MVVM (Model-View-ViewModel) Pattern
**Purpose**: Separates business logic from UI, making code more testable and maintainable.

#### Implementation:

**Model Layer** (`Weather/Models/`)
- **Files**: 
  - `ForecastModel.swift` - Domain models
  - `WeatherAPIModels.swift` - API response models
- **Responsibility**: Data structures and business entities

**View Layer** (`Weather/Views/`)
- **Files**:
  - `HomeView.swift` - Main screen
  - `ForecastView.swift` - Forecast display
  - `WeatherView.swift` - Weather list
  - Components in `Components/` folder
- **Responsibility**: UI presentation only

**ViewModel Layer** (`Weather/ViewModels/`)
- **File**: `WeatherViewModel.swift`
- **Responsibility**: 
  - Transforms Model data for View
  - Manages UI state (`@Published` properties)
  - Handles business logic
- **Location**: `Weather/ViewModels/WeatherViewModel.swift`

```swift
// ViewModel acts as intermediary
@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var cityName: String = "Cairo"
    @Published var temperature: Int = 0
    // ... other published properties
    
    func fetchWeather() async {
        // Business logic here
    }
}
```

**Usage in View** (`Weather/Views/Main/HomeView.swift`)
- **Location**: Lines 17, 51-64
```swift
@StateObject private var viewModel = WeatherViewModel(city: "Cairo,EG")

// View observes ViewModel
Text(viewModel.cityName)
Text("\(viewModel.temperature)°")
```

---

### 2. Protocol-Oriented Programming (POP)
**Purpose**: Swift's approach to polymorphism using protocols instead of inheritance.

#### Implementation:

**Service Protocol** (`Weather/Services/WeatherService.swift`)
- **Location**: Lines 11-14
- **Usage**: Defines contract for weather data fetching

```swift
protocol WeatherServiceProtocol {
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeatherResponse
    func fetchForecast(for city: String) async throws -> ForecastResponse
}
```

**Benefits**:
- Testability: Can create mock implementations
- Flexibility: Easy to swap implementations
- No inheritance hierarchy needed

---

### 3. Adapter Pattern
**Purpose**: Converts interface of a class into another interface clients expect.

#### Implementation:

**API to Domain Model Adapter** (`Weather/ViewModels/WeatherViewModel.swift`)
- **Location**: Lines 57-67, 84-111
- **How it works**: Converts `ForecastResponse` (API model) to `Forecast` (domain model)

```swift
// Adapts API response to domain model
hourlyForecasts = hourlyItems.map { item in
    Forecast(
        date: Date(timeIntervalSince1970: item.dt),
        weather: item.weather.first?.mapped ?? .clear,
        temperature: Int(item.main.temp.rounded()),
        // ... adapts API data to Forecast model
    )
}
```

**Weather Condition Adapter** (`Weather/Models/WeatherAPIModels.swift`)
- **Location**: Lines 65-88
- **How it works**: Maps OpenWeatherMap condition codes to app's Weather enum

```swift
extension CurrentWeatherResponse.WeatherCondition {
    var mapped: Weather {
        // Adapts API condition codes to app's Weather enum
        switch id {
        case 200...232: return .stormy
        case 800: return .sunny
        // ...
        }
    }
}
```

---

### 4. Strategy Pattern
**Purpose**: Defines a family of algorithms, encapsulates each one, and makes them interchangeable.

#### Implementation:

**Icon Selection Strategy** (`Weather/Models/ForecastModel.swift`)
- **Location**: Lines 35-63
- **How it works**: Different icon selection strategies based on weather condition and time of day

```swift
var icon: String {
    let isDay = hour >= 6 && hour < 18
    
    switch weather {
    case .clear:
        return isDay ? "Sun cloud mid rain" : "Moon cloud fast wind"
    case .stormy:
        return isDay ? "Sun cloud angled rain" : "Moon cloud mid rain"
    // ... different strategies for different conditions
    }
}
```

---

### 5. Factory Pattern (Implicit)
**Purpose**: Creates objects without specifying the exact class of object that will be created.

#### Implementation:

**Forecast Factory Methods** (`Weather/Models/ForecastModel.swift`)
- **Location**: Lines 66-94
- **How it works**: Static factory methods create Forecast instances

```swift
extension Forecast {
    static let hourly: [Forecast] = [
        Forecast(date: .now, weather: .rainy, ...),
        // Factory creates Forecast instances
    ]
}
```

**ViewModel Initialization** (`Weather/ViewModels/WeatherViewModel.swift`)
- **Location**: Line 28
- **How it works**: Default parameter uses WeatherService singleton

```swift
init(service: WeatherServiceProtocol = WeatherService.shared, city: String = "Cairo,EG") {
    // Uses singleton instance by default
}
```

---

### 6. Singleton Pattern
**Purpose**: Ensures a class has only one instance and provides a global point of access to it.

#### Implementation:

**WeatherService Singleton** (`Weather/Services/WeatherService.swift`)
- **Location**: Lines 57-62
- **How it works**: Private initializer prevents external instantiation, static `shared` property provides single instance
- **Thread-Safe**: Swift's static properties are thread-safe by default

```swift
final class WeatherService: WeatherServiceProtocol {
    // MARK: - Singleton
    static let shared = WeatherService()
    
    private let apiKey = Secrets.apiKey
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let session: URLSession
    
    // MARK: - Private Initializer (Singleton Pattern)
    private init(session: URLSession = .shared) {
        self.session = session
    }
}
```

**Usage in ViewModel** (`Weather/ViewModels/WeatherViewModel.swift`)
- **Location**: Line 28
- **How it works**: Default parameter uses singleton instance

```swift
init(service: WeatherServiceProtocol = WeatherService.shared, city: String = "Cairo,EG") {
    self.service = service  // Uses singleton by default
}
```

**Benefits**:
- **Single Instance**: Only one WeatherService instance exists throughout app lifecycle
- **Resource Efficiency**: Shared URLSession and configuration
- **Global Access**: Easy access from anywhere: `WeatherService.shared`
- **Thread-Safe**: Swift static properties are thread-safe
- **Still Testable**: Can inject mock service for testing (protocol-based)

**Why Singleton for WeatherService?**
- Manages shared resources (API key, base URL, URLSession)
- Stateless service - no need for multiple instances
- Multiple ViewModels can share the same service instance
- Reduces memory footprint
- Centralized configuration management

---

### 7. Observer Pattern
**Purpose**: Defines a one-to-many dependency between objects so that when one object changes state, all dependents are notified.

#### Implementation:

**SwiftUI @Published Properties** (`Weather/ViewModels/WeatherViewModel.swift`)
- **Location**: Lines 14-22
- **How it works**: Views automatically update when `@Published` properties change

```swift
@Published var cityName: String = "Cairo"
@Published var temperature: Int = 0
// Views observe these and update automatically
```

**Usage in View** (`Weather/Views/Main/HomeView.swift`)
- **Location**: Lines 50-51
```swift
Text(viewModel.cityName)  // Automatically updates when cityName changes
Text("\(viewModel.temperature)°")  // Automatically updates when temperature changes
```

---

### 8. Error Handling Pattern
**Purpose**: Centralized error handling with custom error types.

#### Implementation:

**Custom Error Enum** (`Weather/Services/WeatherService.swift`)
- **Location**: Lines 17-51
- **How it works**: Defines all possible weather-related errors

```swift
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case invalidAPIKey
    case noInternetConnection
    case apiLimitReached
    case decodingError(Error)
    
    var errorDescription: String? {
        // User-friendly error messages
    }
}
```

**Error Handling in ViewModel** (`Weather/ViewModels/WeatherViewModel.swift`)
- **Location**: Lines 72-76
```swift
catch let error as WeatherError {
    errorMessage = error.errorDescription ?? error.localizedDescription
}
```

---

## Project Structure

```
Weather/
├── Models/              # Data models (SRP)
│   ├── ForecastModel.swift
│   └── WeatherAPIModels.swift
├── ViewModels/          # MVVM ViewModels
│   └── WeatherViewModel.swift
├── Views/               # SwiftUI Views
│   ├── Main/
│   ├── Detail/
│   ├── Components/
│   └── Navigation/
├── Services/            # Business logic layer
│   └── WeatherService.swift
└── Utils/               # Utilities and extensions
    ├── Extensions.swift
    └── Shapes.swift
```

---

## Code Examples

### Dependency Injection Example

**File**: `Weather/ViewModels/WeatherViewModel.swift`
```swift
// Line 24: Depends on abstraction
private let service: WeatherServiceProtocol

// Line 28: Dependency injection with singleton default
init(service: WeatherServiceProtocol = WeatherService.shared, city: String = "Cairo,EG") {
    self.service = service  // Can inject mock for testing
}
```

### Singleton Pattern Example

**File**: `Weather/Services/WeatherService.swift`
```swift
// Line 57: Singleton instance
static let shared = WeatherService()

// Line 60: Private initializer prevents external instantiation
private init(session: URLSession = .shared) {
    self.session = session
}

// Usage: WeatherService.shared.fetchCurrentWeather(for: "Cairo,EG")
```

### Protocol Usage Example

**File**: `Weather/Services/WeatherService.swift`
```swift
// Line 11-14: Protocol definition
protocol WeatherServiceProtocol {
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeatherResponse
    func fetchForecast(for city: String) async throws -> ForecastResponse
}

// Line 54: Conformance
final class WeatherService: WeatherServiceProtocol {
    // Implementation
}
```

### MVVM Example

**File**: `Weather/Views/Main/HomeView.swift`
```swift
// Line 17: ViewModel instance
@StateObject private var viewModel = WeatherViewModel(city: "Cairo,EG")

// Lines 50-51: View observes ViewModel
Text(viewModel.cityName)
Text("\(viewModel.temperature)°")
```

---

## Summary

### SOLID Principles Applied:
1. ✅ **SRP**: Each class has a single, well-defined responsibility
2. ✅ **OCP**: Protocol-oriented design allows extension without modification
3. ✅ **LSP**: Protocol conformance ensures substitutability
4. ✅ **ISP**: Focused, minimal protocols
5. ✅ **DIP**: High-level modules depend on abstractions (protocols)

### Design Patterns Used:
1. ✅ **MVVM**: Clear separation of concerns
2. ✅ **Protocol-Oriented Programming**: Swift-native approach
3. ✅ **Adapter Pattern**: API to domain model conversion
4. ✅ **Strategy Pattern**: Icon selection based on conditions
5. ✅ **Factory Pattern**: Object creation methods
6. ✅ **Singleton Pattern**: Single WeatherService instance
7. ✅ **Observer Pattern**: SwiftUI @Published properties
8. ✅ **Error Handling Pattern**: Centralized error management

### Benefits:
- **Testability**: Easy to mock dependencies
- **Maintainability**: Clear separation of concerns
- **Flexibility**: Easy to swap implementations
- **Scalability**: Easy to add new features
- **Code Reusability**: Protocol-based design promotes reuse

---

*Last Updated: 2024*
*Project: Weather App*
*Architecture: MVVM with Protocol-Oriented Design*
