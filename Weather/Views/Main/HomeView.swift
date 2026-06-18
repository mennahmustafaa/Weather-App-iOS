//
//  HomeView.swift
//  Weather
//
//

import SwiftUI
import BottomSheet

enum BottomSheetPosition: CGFloat, CaseIterable {
    case top = 0.83 // 702/844
    case middle = 0.385 // 325/844
}

struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel(city: "Cairo,EG")
    @State var bottomSheetPosition: BottomSheetPosition = .middle
    @State var bottomSheetTranslation: CGFloat = BottomSheetPosition.middle.rawValue
    @State var hasDragged: Bool = false
    
    var bottomSheetTranslationProrated: CGFloat {
        (bottomSheetTranslation - BottomSheetPosition.middle.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.middle.rawValue)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                let imageOffset = screenHeight + 36
                
                ZStack {
                    // MARK: Background Color
                    Color.background
                        .ignoresSafeArea()
                    
                    // MARK: Background Image
                    Image("Background")
                        .resizable()
                        .ignoresSafeArea()
                        .offset(y: -bottomSheetTranslationProrated * imageOffset)
                    
                    // MARK: House Image
                    Image("House")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.top, 257)
                        .offset(y: -bottomSheetTranslationProrated * imageOffset)
                    
                    // MARK: Current Weather
                    VStack(spacing: -10 * (1 - bottomSheetTranslationProrated)) {
                        if viewModel.isLoadingCurrentWeather && viewModel.temperature == 0 {
                            // Show skeleton while loading
                            WeatherSkeletonView()
                        } else {
                            Text(viewModel.cityName)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            
                            VStack {
                                Text(attributedString)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .id("\(viewModel.temperature)-\(viewModel.conditionText)-\(hasDragged)")
                                
                                Text("H:\(viewModel.high)°   L:\(viewModel.low)°")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.white)
                                    .opacity(1 - bottomSheetTranslationProrated)
                                    .id("\(viewModel.high)-\(viewModel.low)")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 51)
                    .offset(y: -bottomSheetTranslationProrated * 46)
                    
                    // MARK: Bottom Sheet
                    BottomSheetView(position: $bottomSheetPosition) {
//                        Text(bottomSheetTranslationProrated.formatted())
                    } content: {
                        ForecastView(viewModel: viewModel, bottomSheetTranslationProrated: bottomSheetTranslationProrated)
                    }
                    .onBottomSheetDrag { translation in
                        bottomSheetTranslation = translation / screenHeight
                        
                        withAnimation(.easeInOut) {
                            if bottomSheetPosition == BottomSheetPosition.top {
                                hasDragged = true
                            } else {
                                hasDragged = false
                            }
                        }
                    }
                    
                    // MARK: Tab Bar
                    TabBar(action: {
                        bottomSheetPosition = .top
                    })
                    .offset(y: bottomSheetTranslationProrated * 115)
                    
                    // MARK: Error Alert
                    if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Button {
                                    Task {
                                        await viewModel.fetchWeather()
                                    }
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.bottomSheetBackground.opacity(0.9))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                // Only fetch on initial load, don't block UI
                if viewModel.temperature == 0 {
                    await viewModel.fetchWeather()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CitySelected"))) { notification in
                if let cityQuery = notification.object as? String {
                    viewModel.updateCity(cityQuery)
                    Task {
                        await viewModel.fetchWeather()
                    }
                }
            }
        }
    }
    
    private var attributedString: AttributedString {
        let tempString = "\(viewModel.temperature)°"
        let separator = hasDragged ? " | " : "\n "
        let weatherString = viewModel.conditionText.isEmpty ? "" : viewModel.conditionText
        var string = AttributedString(tempString + (weatherString.isEmpty ? "" : separator + weatherString))
        
        if let temp = string.range(of: tempString) {
            string[temp].font = .system(size: (96 - (bottomSheetTranslationProrated * (96 - 20))), weight: hasDragged ? .semibold : .thin)
            string[temp].foregroundColor = .white
        }
        
        if let pipe = string.range(of: " | ") {
            string[pipe].font = .title3.weight(.semibold)
            string[pipe].foregroundColor = .white.opacity(bottomSheetTranslationProrated)
        }
        
        if !weatherString.isEmpty, let weather = string.range(of: weatherString) {
            string[weather].font = .title3.weight(.semibold)
            string[weather].foregroundColor = .white
        }
        
        return string
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
