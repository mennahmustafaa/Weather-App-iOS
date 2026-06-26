# Weather App 🌤️

A beautiful, modern iOS weather application built with SwiftUI that displays real-time weather data from OpenWeatherMap API. Features a sleek UI with smooth animations, interactive bottom sheets, and comprehensive weather forecasting.



![iOS](https://img.shields.io/badge/iOS-15.5+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

##  Features

-  **Real-time Weather Data**: Fetches live weather data from OpenWeatherMap API
-  **City Search**: Search and select any city worldwide
-  **5-Day Forecast**: View detailed 5-day weather forecast with 3-hour intervals
-  **Temperature Display**: Current temperature, high/low temperatures
-  **Beautiful UI**: Modern design with smooth animations and interactive bottom sheets
-  **Weather Icons**: Dynamic weather icons based on conditions and time of day
-  **Responsive Design**: Optimized for all iPhone screen sizes
-  **Fast Performance**: Optimized API calls with progressive data loading
-  **Error Handling**: Graceful error handling for network issues and API errors



##  Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture pattern and implements **SOLID principles** and modern design patterns.

### Design Patterns Used

- **MVVM**: Clear separation of concerns
-  **Protocol-Oriented Programming**: Swift-native approach
- **Singleton Pattern**: Single WeatherService instance
-  **Adapter Pattern**: API to domain model conversion
-  **Strategy Pattern**: Icon selection based on conditions
- **Observer Pattern**: SwiftUI @Published properties
-  **Error Handling Pattern**: Centralized error management

For detailed architecture documentation, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## 📋 Requirements

- iOS 15.5+
- Xcode 13.4+
- Swift 5.0+
- OpenWeatherMap API key (free tier available)

##  Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/WeatherApp.git
   cd WeatherApp
   ```

2. **Open the project**
   ```bash
   open Weather.xcodeproj
   ```

3. **Configure API Key**
   - Copy `Weather/Services/Secrets.swift.template` to `Weather/Services/Secrets.swift`
   - Open `Weather/Services/Secrets.swift`
   - Replace the placeholder API key with your own:
   ```swift
   enum Secrets {
       static let apiKey = "YOUR_API_KEY_HERE"
   }
   ```
   *Note: `Secrets.swift` is added to `.gitignore`, preventing your secret keys from ever being exposed or committed to Git.*

4. **Get your API Key**
   - Sign up at [OpenWeatherMap](https://openweathermap.org/api)
   - Get your free API key
   - The free tier includes 60 calls/minute and 1,000,000 calls/month

5. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

##  Configuration

### API Endpoint

The app uses the OpenWeatherMap 5-Day / 3-Hour Forecast API:

```
https://api.openweathermap.org/data/2.5/forecast?q={city}&units=metric&appid={API_KEY}
```

### Default Location

The app defaults to **Cairo, Egypt**. You can change this in:
- `Weather/ViewModels/WeatherViewModel.swift` (line 28)
- Or search for any city using the search feature

## 📁 Project Structure

```
Weather/
├── Models/              # Data models
│   ├── ForecastModel.swift
│   └── WeatherAPIModels.swift
├── ViewModels/          # MVVM ViewModels
│   ├── WeatherViewModel.swift
│   └── CitySearchViewModel.swift
├── Views/               # SwiftUI Views
│   ├── Main/
│   │   ├── ContentView.swift
│   │   └── HomeView.swift
│   ├── Detail/
│   │   ├── ForecastView.swift
│   │   └── WeatherView.swift
│   ├── Components/
│   │   ├── ForecastCard.swift
│   │   ├── WeatherWidget.swift
│   │   ├── SegmentedControl.swift
│   │   └── Blur.swift
│   └── Navigation/
│       ├── NavigationBar.swift
│       └── TabBar.swift
├── Services/            # Business logic layer
│   └── WeatherService.swift
└── Utils/               # Utilities and extensions
    ├── Extensions.swift
    └── Shapes.swift
```

## 🛠️z
## 📖 Usage

### Viewing Weather

1. **Main Screen**: Displays current weather for the default city (Cairo)
2. **Search Cities**: Tap the search icon to search for any city
3. **Select City**: Tap on a city widget to set it as the main location
4. **View Forecast**: Swipe up the bottom sheet to see hourly and daily forecasts

### Features

- **Hourly Forecast**: Swipe to see weather for the next 6 hours
- **Daily Forecast**: Switch to daily view for 5-day forecast
- **Interactive Bottom Sheet**: Drag to expand/collapse forecast view
- **Real-time Updates**: Weather data updates automatically

## UI Components

- **Weather Widget**: Displays temperature, high/low, location, and weather icon
- **Forecast Card**: Shows hourly/daily forecast with icons and probability
- **Segmented Control**: Toggle between hourly and daily forecasts
- **Navigation Bar**: Search functionality with custom white placeholder
- **Bottom Sheet**: Interactive forecast view with smooth animations

## API Configuration

### Current Setup

- **API Key**: Configured locally in `Secrets.swift` (gitignored)
- **Base URL**: `https://api.openweathermap.org/data/2.5`
- **Units**: Metric (°C)
- **Default City**: Cairo, Egypt

### Supported Formats

- City name: `"Cairo"`
- City with country code: `"Cairo,EG"`
- City with country name: `"Cairo, Egypt"`

##  Error Handling

The app handles various error scenarios:

- ❌ Invalid API key
- ❌ No internet connection
- ❌ API limit reached
- ❌ City not found
- ❌ Server errors
- ❌ Network timeouts

All errors are displayed with user-friendly messages and retry options.

##  Performance Optimizations

- **Progressive Loading**: Current weather displays immediately, forecast updates separately
- **Debounced Search**: City search waits 0.5 seconds before API call
- **Optimized URLSession**: Configured timeouts and caching
- **Efficient State Management**: Minimal view updates with proper @Published usage

##  Code Quality

- ✅ SOLID Principles
- ✅ MVVM Architecture
- ✅ Protocol-Oriented Design
- ✅ Error Handling
- ✅ Type Safety
- ✅ Code Documentation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

##  Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) for providing the weather API
- [BottomSheet](https://github.com/Wouter125/BottomSheet) library for bottom sheet functionality
- Design inspiration from modern weather apps

## 📧 Contact

For questions or suggestions, please open an issue on GitHub.

---

