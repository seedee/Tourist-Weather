//
//  NavBarView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

struct NavBarView: View {

    // MARK:  Varaible section - set up variable to use WeatherMapPlaceViewModel and SwiftData

    /*
     set up the @EnvironmentObject for WeatherMapPlaceViewModel
     Set up the @Environment(\.modelContext) for SwiftData's Model Context
     Use @Query to fetch data from SwiftData models

     State variables to manage locations and alertmessages
     */

    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @State private var tempLocation = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @FocusState private var focus: Bool
    
    
    // MARK:  Configure the look of tab bar

    init() {
        // Customize TabView appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .center) {
                Image("BG")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.75)
                HStack {
                    Label("Change Location", systemImage: "location.fill")
                        .padding(.horizontal)
                        .bold()
                    TextField("Enter New Location", text: $tempLocation)
                        .padding(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focus)
                        .onSubmit {
                            weatherMapPlaceViewModel.newLocation = tempLocation
                            Task {
                                do {
                                    try await weatherMapPlaceViewModel.getCoordinatesForCity()
                                    _ = try await weatherMapPlaceViewModel.fetchWeatherData(lat: weatherMapPlaceViewModel.coords?.latitude ?? 51.5033768, lon: weatherMapPlaceViewModel.coords?.longitude ?? -0.0795183) // Fallback to London
                                } catch {
                                    print("Error: \(error)")
                                    isLoading = false
                                }
                            }
                        }
                }
                .shadow(color: .blue, radius: 10)
                //.fixedSize()
            }
            .frame(maxHeight: 70) // Search bar height
            TabView {
                CurrentWeatherView()
                    .tabItem{
                        Label("Now", systemImage:  "sun.max.fill")
                    }
                ForecastWeatherView()
                    .tabItem{
                        Label("5-Day Weather", systemImage: "calendar")
                    }
                MapView()
                    .tabItem {
                        Label("Place Map", systemImage: "map")
                    }
                VisitedPlacesView()
                    .tabItem{
                        Label("Stored Places", systemImage: "globe")
                    }
            } // TabView
            .onAppear {
                // MARK:  Write code to manage what happens when this view appears
            }
            
        }//VStack - Outer
        // add frame modifier and other modifiers to manage this view
    }
}

#Preview {
    NavBarView()
}
