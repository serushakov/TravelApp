//
//  StepDescriptor.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import CoreLocation
import Foundation

enum StepError: Error {
    case poiNotDefined
}

enum StepType {
    case arrival
    case departure
    case hub
    case step
}

/**
 There are different types of steps, like arrival step, departure step and regular
 user created step (Step). For the purposes of simplified data exchange this struct
 will be the common data format that can represent all types of steps
 */
struct StepDescriptor: Identifiable {
    var id = UUID()

    let type: StepType
    let title: String
    let location: CLLocationCoordinate2D
    let arrival: Date?
    let departure: Date?
    let ordinal: Int?

    init(type: StepType, title: String, location: CLLocationCoordinate2D, arrival: Date, departure: Date) {
        self.type = type
        self.title = title
        self.location = location
        self.arrival = arrival
        self.departure = departure
        ordinal = nil
    }

    init(type: StepType, title: String, location: CLLocationCoordinate2D, arrival: Date) {
        self.type = type
        self.title = title
        self.location = location
        self.arrival = arrival
        departure = nil
        ordinal = nil
    }

    init(type: StepType, title: String, location: CLLocationCoordinate2D, departure: Date) {
        self.type = type
        self.title = title
        self.location = location
        arrival = nil
        self.departure = departure
        ordinal = nil
    }

    init?(fromStep step: Step, ordinal: Int) {
        guard let poi = step.poi else {
            return nil
        }
        type = .step
        title = poi.name!
        location = CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
        arrival = step.visitStart
        departure = step.visitEnd
        self.ordinal = ordinal
    }
}
