//
//  ForecastWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct ForecastWeatherView: View {
    
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        VStack() {
            HourlyWeatherView()
            DailyWeatherView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Image("sky")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .opacity(0.66)
        )
    }
}

#Preview {
    ForecastWeatherView()
}
