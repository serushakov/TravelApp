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
    @State var selectedLocation: MKMapItem?
    @State var showConfirmation: Bool = false

    var isVisible: Bool
    let onTripAdded: (Trip) -> Void

    var confirmationLabel: String {
        "Create a trip to \(selectedLocation?.name ?? "nil")?"
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $locationSearchService.searchQuery)
                .placeholder("Search for destinations")
                .padding(.horizontal, 10)

            Divider()

            if locationSearchService.state == .loading {
                ProgressView()
                    .padding()
                Spacer()
            } else if !locationSearchService.searchQuery.isEmpty && locationSearchService.completions.isEmpty {
                Text("Nothing found")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                SwiftUI.List {
                    ForEach(locationSearchService.completions
                        .compactMap { $0.placemark.title == nil ? nil : $0 }) { item in
                        HStack {
                            Text(item.placemark.title!)
                            Spacer()
                            Tag(text: "City", color: .green)
                        }
                        .background(Color.clear)
                        .listRowSeparator(.hidden, edges: .top)
                        .listRowSeparator(.visible, edges: .bottom)
                        .contentShape(Rectangle()) // Needed to capture taps over the whole area of a List item
                        .onTapGesture {
                            selectedLocation = item
                            showConfirmation = true
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
        .background(.clear)
        .confirmationDialog(confirmationLabel, isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Create") {
                createTrip(to: selectedLocation!)
            }
        } message: {
            Text(confirmationLabel)
        }
    }

    func createTrip(to: MKMapItem) {
        guard let region = to.placemark.region as? CLCircularRegion else {
            return
        }

        let destination = Destination(context: managedObjectContext)
        destination.name = to.name
        destination.country = to.placemark.country
        destination.latitude = region.center.longitude
        destination.longitude = region.center.latitude
        destination.radius = region.radius

        let trip = Trip(context: managedObjectContext)
        trip.destination = destination
        trip.createdAt = Date.now

        do {
            try managedObjectContext.save()
            onTripAdded(trip)
        } catch {}
    }
}

struct TripCreation_Previews: PreviewProvider {
    @State static var show = true

    static var previews: some View {
        ZStack {}.sheet(isPresented: $show) {
            TripCreation(isVisible: false) { _ in }
        }
    }
}
