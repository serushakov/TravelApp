//
//  TripDetail.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI

struct TripDetail: View {
    let trip: Trip
    let onBack: () -> Void

    var body: some View {
        TabView {
            NavigationView {
                TripSummary(trip: trip, onBack: onBack)
            }.tabItem {
                Image(systemName: "book.fill")
                Text("Summary")
            }
            NavigationView {
                TripDaysList()
            }.tabItem {
                Image(systemName: "calendar")
                Text("Days")
            }
        }
    }
}

struct TripDetail_Previews: PreviewProvider {
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

        return TripDetail(trip: trip) {}
            .environment(\.managedObjectContext, moc)
    }
}
