//
//  TripDaysList.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI
let dayDurationInSeconds: TimeInterval = 60 * 60 * 24

extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}

struct TripDaysList: View {
    let trip: Trip

    var days: [Date] {
        guard let arrival = trip.arrival, let departure = trip.departure else { return [] }

        return stride(from: arrival, to: departure, by: dayDurationInSeconds)
            .map { $0 }
    }

    var body: some View {
        VStack {
            if days.count > 0 {
                SwiftUI.List {
                    ForEach(days, id: \.self) { date in
                        NavigationLink {
                            TripDayItinerary(trip: trip, day: date)
                        } label: {
                            Text(date, format: Date.FormatStyle().day().month())
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                VStack {
                    Text("Arrival and departure dates are not set")
                }
            }
        }
    }
}

struct TripDaysList_Previews: PreviewProvider {
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
        trip.arrival = Date.now
        trip.departure = Date.now.advanced(by: 60 * 60 * 24 * 5)

        return NavigationView {
            TripDaysList(trip: trip)
                .environment(\.managedObjectContext, moc)
        }
    }
}
