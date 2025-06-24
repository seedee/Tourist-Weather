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
                        VStack(alignment: .leading) {
                            Text(location.name)
                                .font(.headline)
                            HStack {
                                Text("Coordinates:")
                                    .font(.caption)
                                Text(String(format: "%.5f, %.5f", location.lat, location.lon))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            Text("Added \(location.timestamp, style: .date)")
                                .font(.caption)
                        }
                        .padding()
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        )
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteLocations)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
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
