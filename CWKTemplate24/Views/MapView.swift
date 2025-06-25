//
//  MapView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI
import MapKit
import Combine

struct MapView: View {

    // MARK:  set up the @EnvironmentObject for WeatherMapPlaceViewModel
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @State private var mapCameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5033768, longitude: -0.0795183),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    @State private var selectedPlace: PlaceAnnotationDataModel?
    @State private var showingPlaceDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            Map(position: $mapCameraPosition) {
                ForEach(weatherMapPlaceViewModel.annotations) { place in
                    Annotation(place.name, coordinate: place.coords) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        .onTapGesture {
                            selectedPlace = place
                            showingPlaceDetails = true
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .frame(height: 350)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(weatherMapPlaceViewModel.annotations) { place in
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(place.name)
                                    .font(.headline)
                                Text(place.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let info = place.info {
                                    Text(info)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                        .onTapGesture {
                            selectedPlace = place
                            showingPlaceDetails = true
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
        }
        .onReceive(weatherMapPlaceViewModel.$coords) { newCoords in
            if let coords = newCoords {
                withAnimation {
                    mapCameraPosition = .region(MKCoordinateRegion(
                        center: coords,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    ))
                }
            }
        }
        .task {
            do {
                try await weatherMapPlaceViewModel.setAnnotations()
            } catch {
                print("Error loading annotations: \(error)")
            }
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

struct PlaceDetailView: View {
    let place: PlaceAnnotationDataModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text(place.name)
                    .font(.largeTitle)
                    .bold()
                
                Text("Category: \(place.category)")
                    .font(.headline)
                
                if let info = place.info {
                    Text(info)
                        .font(.body)
                }
                
                if let urlString = place.url,
                   let url = URL(string: urlString) {
                    Link("Learn More...", destination: url)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}
#Preview {
    MapView()
}
