//
//  VisitedPlacesView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI
import SwiftData

struct VisitedPlacesView: View {
/*
    Set up the @Environment(\.modelContext) for SwiftData's Model Context
    Use @Query to fetch data from SwiftData models
*/
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LocationModel.timestamp, order: .reverse) private var locations: [LocationModel]
    
    var body: some View {
        VStack {
            Text("Weather Locations in Database")
                .padding()
                .bold()
            
            if locations.isEmpty {
                Spacer()
                Text("No stored locations yet")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(locations, id: \.id) { location in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(location.name)
                                .font(.headline)
                            HStack {
                                Text("Coordinates:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(String(format: "(%.4f, %.4f)", location.lat, location.lon))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            Text("Added: \(location.timestamp, style: .date)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteLocations)
                }
                .listStyle(PlainListStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("sky")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .opacity(0.66)
        )
    }
    
    private func deleteLocations(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(locations[index])
            }
        }
    }
}

#Preview {
    VisitedPlacesView()
}
