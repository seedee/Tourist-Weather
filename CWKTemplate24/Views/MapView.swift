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
                ForEach(weatherMapPlaceViewModel.annotations) { annotation in
                    Annotation(annotation.name, coordinate: annotation.coords) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            Text(annotation.name)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                        .onTapGesture {
                            selectedPlace = annotation
                            showingPlaceDetails = true
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .frame(height: 350)
            
            // Tourist places list
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(weatherMapPlaceViewModel.annotations) { place in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
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
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
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
