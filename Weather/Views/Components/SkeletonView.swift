//
//  SkeletonView.swift
//  Weather
//
//  Professional skeleton loading view with shimmer effect
//

import SwiftUI

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base color
                Color.white.opacity(0.1)
                
                // Shimmer effect
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * 2)
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
            }
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

struct SkeletonText: View {
    let width: CGFloat
    let height: CGFloat
    
    init(width: CGFloat = 100, height: CGFloat = 20) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        SkeletonView()
            .frame(width: width, height: height)
            .cornerRadius(8)
    }
}

struct WeatherSkeletonView: View {
    var body: some View {
        VStack(spacing: -10) {
            // City name skeleton
            SkeletonText(width: 120, height: 32)
            
            VStack(spacing: 8) {
                // Temperature skeleton
                SkeletonText(width: 150, height: 80)
                
                // High/Low skeleton
                SkeletonText(width: 100, height: 24)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 51)
    }
}

struct ForecastCardSkeleton: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.forecastCardBackground.opacity(0.2))
                .frame(width: 60, height: 146)
            
            VStack(spacing: 16) {
                SkeletonText(width: 40, height: 16)
                SkeletonView()
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                SkeletonText(width: 40, height: 24)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
        }
    }
}
