//
//  PoiSearch.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 19.4.2022.
//

import MapKit
import SwiftUI

enum Category {
    case attraction
    case service
    case food
    case transport
    case city
}

struct PoiSearch: View {
    @Environment(\.managedObjectContext) var moc

    let trip: Trip
    let onPoiPicked: (_ poi: PointOfInterest) -> Void
    let onClose: () -> Void

    @StateObject var locationSearchService: LocationSearchService

    init(trip: Trip, onPoiPicked: @escaping (_ poi: PointOfInterest) -> Void, onClose: @escaping () -> Void) {
        self.trip = trip
        self.onClose = onClose
        self.onPoiPicked = onPoiPicked

        let region = PoiSearch.getTripRegion(trip: trip)

        self._locationSearchService = StateObject(wrappedValue: LocationSearchService(
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
//            .filter(isCity)
            .compactMap { $0.placemark.title == nil ? nil : $0 }

        print(a.map { $0.pointOfInterestCategory })

        return a
    }

    func createPoi(from mapItem: MKMapItem) async {
        guard let name = mapItem.name else { return }

        var photoResult: RandomPhotoResult?

        do {
            photoResult = try await ThumbnailSearchService.fetchRandomPhoto(query: name)
        } catch {
            // TODO: Handle
        }

        let poi = PointOfInterest(context: moc)
        poi.name = name
        poi.address = mapItem.placemark.title
        poi.latitude = mapItem.placemark.coordinate.latitude
        poi.longitude = mapItem.placemark.coordinate.longitude
        poi.thumbnail = photoResult?.urls.small_s3
        poi.blurhash = photoResult?.blur_hash
        poi.addedAt = Date.now

        onPoiPicked(poi)
    }

    func getPoiCategory(_ poi: MKMapItem) -> Category? {
        guard let category = poi.pointOfInterestCategory else {
            if poi.placemark.title == poi.placemark.locality {
                return .city
            }
            return nil
        }

        switch category {
        case .airport, .publicTransport:
            return .transport
        case .amusementPark, .aquarium, .movieTheater, .zoo, .winery, .nightlife, .theater, .stadium, .park, .museum, .nationalPark:
            return .attraction
        case .atm, .bank, .carRental, .evCharger, .fitnessCenter, .gasStation, .hospital, .laundry, .library, .parking, .pharmacy, .postOffice, .police, .hotel, .store, .restroom:
            return .service
        case .restaurant, .bakery, .winery, .foodMarket:
            return .food
        default:
            return nil
        }
    }

    func getIcon(for poi: MKMapItem) -> some View {
        guard let category = getPoiCategory(poi) else {
            return AnyView(EmptyView())
        }

        var icon: (String, Color, SymbolRenderingMode?)?

        switch category {
        case .attraction:
            icon = ("star.fill", .indigo, .none)
        case .service:
            icon = ("bubble.left.and.bubble.right.fill", .pink, .hierarchical)
        case .food:
            icon = ("fork.knife", .orange, .none)
        case .transport:
            icon = ("bus.fill", .blue, .none)
        case .city:
            icon = ("mappin.and.ellipse", .green, .none)
        }

        if let (icon, color, renderingMode) = icon {
            return AnyView(Image(systemName: icon)
                .symbolRenderingMode(renderingMode)
                .font(.system(size: 20))
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.12))
                .clipShape(Circle()))
        }
        return AnyView(EmptyView())
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "New place", closeButtonAction: onClose)
            SearchBar(text: $locationSearchService.searchQuery)
                .placeholder("Search for places")
                .padding(.horizontal, 10)
            Divider()

            if locationSearchService.state == .loading {
                ProgressView()
                    .padding()
                Spacer()
            } else if !locationSearchService.searchQuery.isEmpty && completions.isEmpty {
                Text("Nothing found")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                SwiftUI.List {
                    ForEach(completions) { item in
                        Button {
                            Task {
                                await createPoi(from: item)
                            }
                        } label: {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name!)
                                    Text(item.placemark.title!)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                getIcon(for: item)
                                    .font(.title)
                            }
                        }
                        .background(Color.clear)
                        .listRowSeparator(.hidden, edges: .top)
                        .listRowSeparator(.visible, edges: .bottom)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
    }
}

struct PoiSearch_Previews: PreviewProvider {
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

        return PoiSearch(trip: trip) { _ in } onClose: {}
    }
}
