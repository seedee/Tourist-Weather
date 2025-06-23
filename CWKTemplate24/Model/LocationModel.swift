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
    var id: UUID
    let name: String
    let coords: CLLocationCoordinate2D
    
    init() {
        
    }
}
