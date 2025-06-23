//
//  CurrentWeatherView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct CurrentWeatherView: View {

// MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

// MARK:  set up local @State variable to support this view
    var body: some View {
        VStack {
            Text(weatherMapPlaceViewModel.newLocation)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding()
            if let unix = weatherMapPlaceViewModel.weatherDataModel?.current.dt {
                let date = DateFormatterUtils.formattedDate(from: unix, format: "dd MMM yyyy 'at' h a")
                Text(date)
                    .padding()
                    .bold()
            } else {
                Text("Date & time unavailable")
                    .padding()
                    .bold()
            }
            Grid(alignment: .leading, horizontalSpacing: 80) {
                GridRow {
                    if let weather = weatherMapPlaceViewModel.weatherDataModel {
                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.current.weather[0].icon)@2x.png")) { image in
                            image.resizable()
                        } placeholder: { }
                            .frame(width: 50, height: 50)
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(width: 50, height: 50)
                    }
                    VStack(alignment: .leading) {
                        if let weather = weatherMapPlaceViewModel.weatherDataModel {
                            Text(weather.current.weather.first?.weatherDescription.rawValue.capitalized ?? "Condition unavailable")
                                .bold()
                        }
                        HStack(alignment: .top, spacing: 0) {
                            Text("Feels like: ")
                            if let weather = weatherMapPlaceViewModel.weatherDataModel {
                                Text("\(String(format: "%.0f", weather.current.feelsLike)) ºC")
                            }
                        }
                    }
                }
                GridRow {
                    Image("temperature")
                        .resizable()
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 0) {
                            Text("Temp: ")
                            if let weather = weatherMapPlaceViewModel.weatherDataModel {
                                Text("\(String(format: "%.0f", weather.current.temp)) ºC")
                            }
                        }
                        HStack(alignment: .top, spacing: 0) {
                            Text("H: ")
                            if let weather = weatherMapPlaceViewModel.weatherDataModel {
                                if let today = weather.daily.first {
                                    Text("\(String(format: "%.0f", today.temp.max)) ºC")
                                }
                            }
                            Text("L: ")
                                .padding(.leading)
                            if let weather = weatherMapPlaceViewModel.weatherDataModel {
                                if let today = weather.daily.first {
                                    Text("\(String(format: "%.0f", today.temp.min)) ºC")
                                }
                            }
                        }
                    }
                }
                GridRow {
                    Image("windSpeed")
                        .resizable()
                        .frame(width: 50, height: 50)
                    HStack(alignment: .top, spacing: 0) {
                        Text("Wind Speed: ")
                        if let weather = weatherMapPlaceViewModel.weatherDataModel {
                            Text(
                                "\(Int(weather.current.windSpeed)) m/s"
                            )
                        }
                    }
                }
                GridRow {
                    Image("humidity")
                        .resizable()
                        .frame(width: 50, height: 50)
                    HStack(alignment: .top, spacing: 0) {
                        Text("Humidity: ")
                        if let weather = weatherMapPlaceViewModel.weatherDataModel {
                            Text("\(weather.current.humidity) %")
                        }
                    }
                }
                GridRow {
                    Image("pressure")
                        .resizable()
                        .frame(width: 50, height: 50)
                    HStack(alignment: .top, spacing: 0) {
                        Text("Pressure: ")
                        if let weather = weatherMapPlaceViewModel.weatherDataModel {
                            Text("\(weather.current.pressure) hPa")
                        }
                    }
                }
            }
            Text("Current Air Quality in \(weatherMapPlaceViewModel.newLocation)")
                .padding(.top, 40)
                .bold()
            ZStack(alignment: .top) {
                Image("BG")
                    .resizable()
                    .frame(maxHeight: 130)
                HStack {
                    VStack {
                        Image("so2")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                        if let air = weatherMapPlaceViewModel.airDataModel {
                            if let item = air.list.first {
                                Text(String(format: "%.2f", item.components.so2))
                            }
                        }
                    }
                    VStack {
                        Image("no")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                        if let air = weatherMapPlaceViewModel.airDataModel {
                            if let item = air.list.first {
                                Text(String(format: "%.2f", item.components.no))
                            }
                        }
                    }
                    VStack {
                        Image("voc")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                        if let air = weatherMapPlaceViewModel.airDataModel {
                            if let item = air.list.first {
                                Text(String(format: "%.2f", item.components.co))
                            }
                        }
                    }
                    VStack {
                        Image("pm")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                        if let air = weatherMapPlaceViewModel.airDataModel {
                            if let item = air.list.first {
                                Text(String(format: "%.2f", item.components.pm10))
                            }
                        }
                    }
                }
            }
            .padding()
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

/*#Preview {
    CurrentWeatherView()
}*/
