//
//  TripCreation.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 10.4.2022.
//

import BottomSheet
import MapKit
import SwiftUI

struct TripCreation: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var locationSearchService = LocationSearchService()

    let onFinished: () -> Void

    var completions: [MKMapItem] {
        locationSearchService.completions
            .filter(isCity)
            .compactMap { $0.placemark.title == nil ? nil : $0 }
    }

    func isCity(_ item: MKMapItem) -> Bool {
        // MKMapItem is a city when `locality`(city) matches name of the item
        // There's really no better way to distinguish if MKMapItem is a city or not
        return item.placemark.locality == item.name
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SwiftUI.List {
                    if completions.count > 0 {
                        Section("Results") {
                            ForEach(completions) { item in
                                NavigationLink {
                                    TripDetailsForm(to: item, onFinished: onFinished)
                                        .navigationBarTitle("Details")
                                } label: {
                                    HStack {
                                        Text(item.placemark.title!)
                                        Spacer()
                                        Tag("City", color: .green)
                                    }
                                    .background(Color.clear)
                                    .listRowSeparator(.hidden, edges: .top)
                                    .listRowSeparator(.visible, edges: .bottom)
                                }
                            }
                        }
                    }
                }
                .searchable(text: $locationSearchService.searchQuery, placement: .navigationBarDrawer(displayMode: .always))
                .listStyle(.grouped)
                .overlay {
                    if locationSearchService.state == .loading {
                        ProgressView()
                            .padding()
                        Spacer()
                    } else if completions.isEmpty && !locationSearchService.searchQuery.isEmpty {
                        Text("Nothing found")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    } else if locationSearchService.searchQuery.isEmpty {
                        Text("Type your destination into the search box")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel", action: onFinished)
                }
            }
            .navigationTitle("Search city")
            .navigationBarTitleDisplayMode(.inline)
            .background(.clear)
        }
    }
}

struct TripCreation_Previews: PreviewProvider {
    @State static var show = true

    static var previews: some View {
        ZStack {}.sheet(isPresented: $show) {
            TripCreation {}
        }
    }
}
