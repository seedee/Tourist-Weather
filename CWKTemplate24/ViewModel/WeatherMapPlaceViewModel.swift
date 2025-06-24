//
//  WeatherMapPlaceViewModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

class WeatherMapPlaceViewModel: ObservableObject {
    
    @Published var weatherDataModel: WeatherDataModel?
    @Published var airDataModel: AirDataModel?
    @Published var newLocation = "London"
    @Published var region = MKCoordinateRegion()
    @Published var coords: CLLocationCoordinate2D?
    @Published var annotations: [PlaceAnnotationDataModel] = []
    @Published var locations: [LocationModel] = []
    
    init() {
        self.weatherDataModel = loadInitialData("london.json")
        self.airDataModel = loadInitialData("airQuality.json")
    }

    private func loadInitialData<T: Decodable>(_ filename: String) -> T {
        print("Loading from \(filename)")
        
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in main bundle")
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Error parsing \(filename): \(error)")
        }
    }

    func getCoordinatesForCity() async throws {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(newLocation)
        
        guard let location = placemarks.first?.location?.coordinate else { // Ensure at least one placemark returned and extract its coords
            print("No location found for \"\(newLocation)\"")
            return
        }
        print("Found coordinates (lat: \(location.latitude), lon: \(location.longitude))")
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.coords = location
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
    }
    
    // Fetches both weather and air
    func fetchWeatherData(lat: Double, lon: Double) async throws {
        let key = WeatherAPIKey.getAPIKey
        
        guard
            let weatherURL = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(key)"),
            let airURL = URL(string: "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&units=metric&appid=\(key)")
        else {
            throw NetworkError.invalidURL
        }
        
        do {
            async let weatherDataModel: WeatherDataModel = fetchData(from: weatherURL)
            async let airDataModel: AirDataModel = fetchData(from: airURL)
            let (w, a) = try await (weatherDataModel, airDataModel) // Wait until both finish
            
            DispatchQueue.main.async {
                self.weatherDataModel = w
                self.airDataModel = a
            }
            print("Decoded \(w.timezone)")
        } catch {
            if let decodingError = error as? DecodingError {
                print("Decoding error: \(decodingError)")
            } else {
                print("Error: \(error)")
            }
            throw error
        }
    }
    
    // Helper for any decodable type and any URL
    func fetchData<T: Decodable>(from url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK:  function to get tourist places safely for a  map region and store for use in showing them on a map

    func setAnnotations() async throws{
        guard let coords = self.coords else {
            print("Tried to set annotations with no coordinates available")
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "tourist attractions points of interest"
        searchRequest.region = MKCoordinateRegion(
            center: coords,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            
            // Convert map items to annotation model
            let places = response.mapItems.prefix(5).compactMap { mapItem -> PlaceAnnotationDataModel? in
                guard let name = mapItem.name else { return nil }
                
                return PlaceAnnotationDataModel(
                    name: name,
                    coords: mapItem.placemark.coordinate,
                    category: mapItem.pointOfInterestCategory?.rawValue ?? "Tourist Attraction",
                    url: mapItem.url?.absoluteString,
                    info: mapItem.phoneNumber
                )
            }
            
            // Update annotations on main thread
            await MainActor.run {
                self.annotations = places
            }
            
        } catch {
            print("Error searching for tourist places: \(error)")
            throw error
        }
    }
}
