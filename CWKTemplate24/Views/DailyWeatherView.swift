//
//  DailyWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct DailyWeatherView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        Text("8 Day Forecast Weather for \(weatherMapPlaceViewModel.newLocation)")
            .font(.title)
            .padding()
        
        if let weather = weatherMapPlaceViewModel.weatherDataModel {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(weather.daily) { day in
                        HStack {
                            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(day.weather[0].icon)@2x.png")) { image in
                                image.resizable()
                            } placeholder: { }
                                .frame(width: 50, height: 50)
                                .padding([.leading, .top, .bottom])
                            Spacer()
                            VStack {
                                Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(day.dt)))
                                Text(day.weather.first?.weatherDescription.rawValue.capitalized ?? "Condition unavailable")
                            }
                            .padding(.vertical)
                            Spacer()
                            VStack {
                                Text("Day")
                                Text("\(String(format: "%.0f", day.temp.day)) ºC")
                            }
                            .padding(.vertical)
                            VStack {
                                Text("Night")
                                Text("\(String(format: "%.0f", day.temp.night)) ºC")
                            }
                            .padding([.trailing, .top, .bottom])

                        }
                        .background(.gray.opacity(0.2))
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(width: 50, height: 50)
        }
    }
}

#Preview {
    DailyWeatherView()
}
