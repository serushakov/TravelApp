//
//  HubDetails.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.4.2022.
//

import MapKit
import SwiftUI

struct HubDetails: View {
    let hub: Hub
    let onClose: () -> Void

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: hub.latitude,
            longitude: hub.longitude
        )
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                Map(
                    coordinateRegion: .constant(MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)),
                    annotationItems: [hub]
                ) { _ in
                    MapMarker(coordinate: location)
                }
                .frame(height: 200)

                VStack(alignment: .leading) {
                    Text(hub.name!)
                        .font(.title.bold())
                    Text(hub.address!)
                        .font(.body.bold())
                        .foregroundColor(.secondary)
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                        if let checkin = hub.checkIn {
                            VStack(alignment: .leading) {
                                Text("Check-in")
                                    .foregroundColor(.secondary)
                                Text(checkin, format: Date.FormatStyle().hour().minute().day().month().year())
                            }
                            .stretch(alignment: .leading)
                        }

                        if let checkout = hub.checkOut {
                            VStack(alignment: .leading) {
                                Text("Check-out")
                                    .foregroundColor(.secondary)
                                Text(checkout, format: Date.FormatStyle().hour().minute().day().month().year())
                            }
                            .stretch(alignment: .leading)
                        }
                    }

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
            .frame(minWidth: 0, maxWidth: .infinity)
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

// struct HubDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        HubDetails()
//    }
// }
