//
//  PoiDetails.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 21.4.2022.
//

import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
}

struct PoiDetails: View {
    let poi: PointOfInterest
    let onClose: () -> Void
    @ObservedObject var locationManager = LocationManager()

    @State var estimate: Double? = nil

    var location: CLLocationCoordinate2D {
        let a = CLLocationCoordinate2D(
            latitude: poi.latitude,
            longitude: poi.longitude
        )

        print(a)

        return a
    }

    func getTravelEstimate(from startLocation: CLLocationCoordinate2D) {
        let endLocation = location

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: startLocation.latitude, longitude: startLocation.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: endLocation.latitude, longitude: endLocation.longitude), addressDictionary: nil))
        request.requestsAlternateRoutes = false // if you want multiple possible routes
        request.transportType = .automobile // will be good for cars

        let result = MKDirections(request: request)

        result.calculateETA { response, _ in
            guard let response = response else {
                // TODO: Handle error
                return
            }

            estimate = response.expectedTravelTime
        }
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

                    Text("")
                        .onAppear {
                            if locationManager.authorizationStatus == .authorizedWhenInUse {
                                locationManager.requestLocation()
                            }
                        }
                        .onChange(of: locationManager.authorizationStatus) { status in
                            if status == .authorizedWhenInUse {
                                locationManager.requestLocation()
                            }
                        }
                        .onChange(of: locationManager.location) { value in

                            if let location = value {
                                getTravelEstimate(from: location)
                            }
                        }
                        .onChange(of: estimate) { estimate in
                            print("estimate: \(estimate)")
                        }

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
