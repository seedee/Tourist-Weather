//
//  AirDataModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation

struct AirDataModel: Codable, Identifiable {
    let id = UUID()
    let coord: Coord
    let list: [AirQuality]
}

struct Coord: Codable {
    let lon, lat: Double
}

struct AirQuality: Codable, Identifiable {
    let id = UUID()
    let main: AQIMain
    let components: AQIComponents
    let dt: Int
}

struct AQIMain: Codable {
    let aqi: Int
}

struct AQIComponents: Codable {
    let co, no, no2, o3: Double
    let so2, pm2_5, pm10, nh3: Double
}
