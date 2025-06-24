//
//  PlaceAnnotationDataModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation
import CoreLocation
import MapKit

/* Code  to manage tourist place map pins */

struct PlaceAnnotationDataModel: Identifiable {
    let id = UUID()
    let name: String
    let coords: CLLocationCoordinate2D
    let category: String
    let url: String?
    let info: String?
}

// MapKit annotation wrapper
struct PlaceAnnotation: Identifiable {
    let id = UUID()
    let place: PlaceAnnotationDataModel
}
