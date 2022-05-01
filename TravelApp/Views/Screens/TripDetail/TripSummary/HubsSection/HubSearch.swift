//
//  PoiSearch.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 19.4.2022.
//

import MapKit
import SwiftUI

struct HubDetailsForm: View {
    @Environment(\.managedObjectContext) var moc

    var trip: Trip
    var mapItem: MKMapItem
    let onHubPicked: (Hub) -> Void
    let onCancel: () -> Void

    @State var checkin: Date
    @State var checkout: Date
    @State var name: String

    init(mapItem: MKMapItem, trip: Trip, onHubPicked: @escaping (Hub) -> Void, onCancel: @escaping () -> Void) {
        self.mapItem = mapItem
        self.trip = trip
        self.onHubPicked = onHubPicked
        self.onCancel = onCancel

        _name = State(initialValue: mapItem.name ?? "")
        let checkin = trip.arrival?.advanced(by: 7200) ?? Date.now
        _checkin = State(initialValue: checkin)
        _checkout = State(initialValue: trip.departure ?? checkin)
    }

    func createPoi(from mapItem: MKMapItem) {
        let hub = Hub(context: moc)
        hub.name = name
        hub.address = mapItem.placemark.title
        hub.latitude = mapItem.placemark.coordinate.latitude
        hub.longitude = mapItem.placemark.coordinate.longitude
        hub.addedAt = Date.now
        hub.checkIn = checkin
        hub.checkOut = checkout

        onHubPicked(hub)
    }

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: mapItem.placemark.coordinate.latitude,
            longitude: mapItem.placemark.coordinate.longitude
        )
    }

    var body: some View {
        Form {
            Section {
                Map(
                    coordinateRegion: .constant(MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)),
                    annotationItems: [mapItem]
                ) { _ in
                    MapMarker(coordinate: location)
                }
                .frame(height: 200)
            }
            .listRowInsets(EdgeInsets())

            Section("Place") {
                TextField("Name", text: $name)
                VStack {
                    Text(mapItem.placemark.title!)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                }
            }

            Section {
                DatePicker("Check-in", selection: $checkin)
                DatePicker("Check-out", selection: $checkout, in: checkin ... (trip.departure ?? Date.distantFuture))
            }

            Section {
                VStack {
                    Button("Save") {
                        createPoi(from: mapItem)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel", action: onCancel)
            }
        }
    }
}

struct HubSearch: View {
    let trip: Trip
    var onHubPicked: (_ hub: Hub) -> Void
    let onClose: () -> Void

    @StateObject var locationSearchService: LocationSearchService

    init(trip: Trip, onHubPicked: @escaping (_ hub: Hub) -> Void, onClose: @escaping () -> Void) {
        self.trip = trip
        self.onClose = onClose
        self.onHubPicked = onHubPicked

        let region = HubSearch.getTripRegion(trip: trip)

        _locationSearchService = StateObject(wrappedValue: LocationSearchService(
            region: region
        ))
    }

    static func getTripRegion(trip: Trip) -> MKCoordinateRegion? {
        if let destination = trip.destination {
            let center = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)

            let region = MKCoordinateRegion(center: center, latitudinalMeters: destination.radius, longitudinalMeters: destination.radius)

            return region
        }

        return nil
    }

    var completions: [MKMapItem] {
        let a = locationSearchService.completions
            .compactMap { $0.placemark.title == nil ? nil : $0 }

        print(a.map { $0.pointOfInterestCategory })

        return a
    }

    func isHotel(_ mapItem: MKMapItem) -> Bool {
        return mapItem.pointOfInterestCategory == .hotel
    }

    func getIcon(for mapItem: MKMapItem) -> some View {
        guard isHotel(mapItem) else {
            return AnyView(EmptyView())
        }
        return AnyView(Image(systemName: "bed.double.fill")
            .font(.system(size: 20))
            .foregroundColor(.brown)
            .padding(8)
            .background(.brown.opacity(0.12))
            .clipShape(Circle()))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SwiftUI.List {
                    if completions.count > 0 {
                        Section("Results") {
                            ForEach(completions) { item in
                                NavigationLink {
                                    HubDetailsForm(mapItem: item, trip: trip, onHubPicked: onHubPicked, onCancel: onClose)
                                        .navigationBarTitle("Details")
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.name!)
                                            Text(item.placemark.title!)
                                                .foregroundColor(.secondary)
                                                .font(.callout)
                                        }

                                        Spacer()
                                        getIcon(for: item)
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
                        Text("Type something into the search box")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel", action: onClose)
                }
            }
            .navigationTitle("New stay")
            .navigationBarTitleDisplayMode(.inline)
            .background(.clear)
        }
    }
}

struct HubSearch_Previews: PreviewProvider {
    static let moc = PersistenceController.preview.container.viewContext

    static var previews: some View {
        let trip = Trip(context: moc)
        let destination = Destination(context: moc)
        trip.destination = destination
        destination.name = "Paris"
        destination.country = "France"
        destination.latitude = 48.864716
        destination.longitude = 2.349014
        destination.radius = 28782
        trip.createdAt = Date.now

        return HubSearch(trip: trip, onHubPicked: { _ in }) {}
    }
}
