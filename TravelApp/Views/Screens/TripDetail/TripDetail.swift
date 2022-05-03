//
//  TripDetail.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI

enum Tab {
    case summary
    case days
}

struct TripDetail: View {
    let trip: Trip

    @State var selectedTab = Tab.summary

    private func getTitle() -> String {
        switch selectedTab {
        case .summary:
            if let name = trip.destination?.name {
                return name
            }
            return ""
        case .days:
            return "Days"
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TripSummary(trip: trip)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Summary")
                }
                .tag(Tab.summary)

            TripDaysList(trip: trip)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Days")
                }
                .tag(Tab.days)
        }
        .navigationTitle(getTitle())
        // Toolbar has to be defined here instead of inside tab views
        // otherwise it leads to bugs in navbar
        .toolbar {
            switch selectedTab {
            case .summary:
                EditButton()
            case .days:
                EmptyView()
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

        return NavigationView { TripDetail(trip: trip)
            .environment(\.managedObjectContext, moc)
        }
    }
}
