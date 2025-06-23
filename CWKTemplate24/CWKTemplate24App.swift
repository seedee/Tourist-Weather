//
//  CWKTemplate24App.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI

@main
struct CWKTemplate24App: App {
    // MARK:  create a StateObject - weatherMapPlaceViewModel and inject it as an environmentObject.
    @StateObject var weatherMapPlaceViewModel = WeatherMapPlaceViewModel()

    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environmentObject(weatherMapPlaceViewModel)

        // MARK:  Create a database to store locations using SwiftData
            
        }
    }
}
