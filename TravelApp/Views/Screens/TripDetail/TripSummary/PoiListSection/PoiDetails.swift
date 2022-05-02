//
//  PoiDetails.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 21.4.2022.
//

import MapKit
import SwiftUI

struct PoiDetails: View {
    let poi: PointOfInterest
    let onClose: () -> Void

    @State var estimate: Double? = nil

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: poi.latitude,
            longitude: poi.longitude
        )
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                Map(
                    coordinateRegion: .constant(MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)),
                    annotationItems: [poi]
                ) { _ in
                    MapMarker(coordinate: location)
                }
                .frame(height: 200)

                VStack(alignment: .leading) {
                    Text(poi.name!)
                        .font(.title.bold())
                    Text(poi.address!)
                        .font(.body.bold())
                        .foregroundColor(.secondary)
                    Spacer()
                        .frame(height: 16)
                    Text("Directions")
                        .foregroundColor(.secondary)

                    Button {} label: {
                        Label("Open in Maps", systemImage: "map")
                    }
                    .font(.title3)
                    .buttonStyle(.borderedProminent)
                    Button {} label: {
                        Label("Directions", systemImage: "map")
                    }
                    .font(.title3)
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            }
            .stretch()
            Button {
                onClose()
            } label: {
                Label("Close", systemImage: "xmark.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
            .foregroundColor(.secondary)
            .background(.ultraThickMaterial)
            .clipShape(Circle())
            .padding(8)
        }
    }
}

struct PoiDetails_Previews: PreviewProvider {
    static let moc = PersistenceController.preview.container.viewContext

    static var previews: some View {
        @State var poi: PointOfInterest? = PointOfInterest(context: moc)

        poi?.name = "Louvre Museum"
        poi?.address = "Rue de Rivoli, 75001 Paris, France"
        poi?.latitude = 48.860294
        poi?.longitude = 2.338629

        return VStack {}
            .sheet(item: $poi) { item in PoiDetails(poi: item) {} }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
