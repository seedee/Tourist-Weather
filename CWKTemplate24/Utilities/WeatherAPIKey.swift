//
//  WeatherAPIKey.swift
//  CWKTemplate24
//
//  Created by Daniil Lebedev on 15/06/2025.
//

import Foundation

enum WeatherAPIKey {
    static var getAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("Put your key in API_KEY.xcconfig")
        }
        return key
    }
}
