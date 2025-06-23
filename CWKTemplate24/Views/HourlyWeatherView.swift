//
//  HourlyWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct HourlyWeatherView: View {

    // MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    
    var body: some View {
        Text("Hourly Forecast Weather for \(weatherMapPlaceViewModel.newLocation)")
            .font(.title)
            .padding()
        
        if let weather = weatherMapPlaceViewModel.weatherDataModel {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(weather.hourly) { hour in
                        VStack {
                            VStack(alignment: .leading) {
                                Text(DateFormatterUtils.formattedDateWithDay(from: TimeInterval(hour.dt)))
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(hour.weather[0].icon)@2x.png")) { image in
                                    image.resizable()
                                } placeholder: { }
                                    .frame(width: 50, height: 50)
                                Text("\(String(format: "%.0f", hour.temp)) ºC")
                                Text(hour.weather.first?.weatherDescription.rawValue.capitalized ?? "Condition unavailable")                            }
                            .padding()
                        }
                        .background(.teal)
                    }
                }
                .padding()
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(width: 50, height: 50)
        }
    }
}
/*#Preview {
    HourlyWeatherView()
}*/
