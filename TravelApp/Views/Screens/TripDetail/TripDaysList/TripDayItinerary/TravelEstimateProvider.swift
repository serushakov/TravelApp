//
//  TravelEstimateProvider.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 2.5.2022.
//

import Foundation
import MapKit
import SwiftUI

/**
 Utility class that will calculate and publish travel estimates between two coordinates.
 Publishes 2 estimates: walking and transit
 */
class TravelEstimateProvider: ObservableObject {
    let from: CLLocationCoordinate2D
    let to: CLLocationCoordinate2D

    @Published var walkEstimate: Estimate = .loading
    @Published var busEstimate: Estimate = .loading

    init(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        self.from = from
        self.to = to

        getWalkingEstimate()
        getTransitEstimate()
    }

    func getRequestBase() -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to, addressDictionary: nil))
        request.requestsAlternateRoutes = false // only one route needed

        return request
    }

    func getWalkingEstimate() {
        let request = getRequestBase()
        request.transportType = .walking

        let result = MKDirections(request: request)

        result.calculateETA { response, _ in
            guard let response = response else {
                return
            }

            self.walkEstimate = .loaded(response.expectedTravelTime)
        }
    }

    func getTransitEstimate() {
        let request = getRequestBase()
        request.transportType = .transit

        let result = MKDirections(request: request)

        result.calculateETA { response, _ in
            guard let response = response else {
                return
            }

            self.busEstimate = .loaded(response.expectedTravelTime)
        }
    }
}
