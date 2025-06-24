//
//  LocationModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation
import SwiftData
import CoreLocation

@Model
class LocationModel: Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var timestamp: Date = Date()
    var coords: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    init() {
        
    }
    
    init(name: String, lat: Double, lon: Double) {
        self.id = UUID()
        self.name = name
        self.lat = lat
        self.lon = lon
        self.timestamp = Date()
    }
}
