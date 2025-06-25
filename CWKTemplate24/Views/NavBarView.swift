//
//  NavBarView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI
import SwiftData
import MapKit

struct NavBarView: View {

    // MARK:  Varaible section - set up variable to use WeatherMapPlaceViewModel and SwiftData

    /*
     set up the @EnvironmentObject for WeatherMapPlaceViewModel
     Set up the @Environment(\.modelContext) for SwiftData's Model Context
     Use @Query to fetch data from SwiftData models

     State variables to manage locations and alertmessages
     */

    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [LocationModel]
    @State private var tempLocation = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var focus: Bool
    
    
    // MARK:  Configure the look of tab bar

    init() {
        // Customize TabView appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.clear
        appearance.backgroundImage = UIImage(named: "BG")
        appearance.backgroundImageContentMode = .top
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.black
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = .white
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
                            handleNewLocation()
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
                // Reapply tab bar appearance to ensure it persists
                if let appearance = UITabBar.appearance().standardAppearance.copy() as? UITabBarAppearance {
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }
        .alert("Location Updated", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleNewLocation() {
        guard !tempLocation.isEmpty else { return }
        isLoading = true
        
        // Store current location as previous before attempting change
        let previousLocation = weatherMapPlaceViewModel.newLocation
        let previousCoords = weatherMapPlaceViewModel.coords
        let previousRegion = weatherMapPlaceViewModel.region

        // Temporarily set the new location
        weatherMapPlaceViewModel.newLocation = tempLocation
        
        Task {
            do {
                if let existingLocation = locations.first(where: { $0.name.lowercased() == tempLocation.lowercased() }) {
                    // Use existing coordinates
                    weatherMapPlaceViewModel.coords = existingLocation.coords
                    weatherMapPlaceViewModel.region = MKCoordinateRegion(
                        center: existingLocation.coords,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                    alertMessage = "\(tempLocation) found in database, using stored coordinates."
                    showAlert = true
                    
                    _ = try await weatherMapPlaceViewModel.fetchWeatherData(
                        lat: existingLocation.lat,
                        lon: existingLocation.lon
                    )
                    // Update previous location on success
                    weatherMapPlaceViewModel.previousLocation = tempLocation
                } else {
                    // Get new coordinates
                    try await weatherMapPlaceViewModel.getCoordinatesForCity()
                    
                    // Check if coordinates were actually found
                    guard let coords = weatherMapPlaceViewModel.coords else {
                        throw WeatherMapPlaceViewModel.NetworkError.invalidURL
                    }
                    
                    // Save new location to database
                    let newLocation = LocationModel(
                        name: tempLocation,
                        lat: coords.latitude,
                        lon: coords.longitude
                    )
                    modelContext.insert(newLocation)
                    alertMessage = "\(tempLocation) added to database with (lat: \(String(format: "%.4f", coords.latitude)), lon: \(String(format: "%.4f", coords.longitude)))"
                    showAlert = true
                    
                    // Fetch weather data
                    _ = try await weatherMapPlaceViewModel.fetchWeatherData(
                        lat: coords.latitude,
                        lon: coords.longitude
                    )
                    
                    // Update previous location on success
                    weatherMapPlaceViewModel.previousLocation = tempLocation
                }
                
                // Fetch tourist places
                try await weatherMapPlaceViewModel.setAnnotations()
            } catch {
                weatherMapPlaceViewModel.newLocation = previousLocation
                weatherMapPlaceViewModel.previousLocation = previousLocation
                weatherMapPlaceViewModel.coords = previousCoords
                weatherMapPlaceViewModel.region = previousRegion
                alertMessage = "Error: \(tempLocation) not found. Please try again."
                showAlert = true
            }
            
            isLoading = false
            tempLocation = ""
            focus = false
        }
    }
}

#Preview {
    NavBarView()
}
