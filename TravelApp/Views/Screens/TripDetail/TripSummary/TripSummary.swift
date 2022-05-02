//
//  TripSummary.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI

struct TripSummary: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.editMode) private var editMode

    let trip: Trip

    @FetchRequest var lists: FetchedResults<List>
    @FetchRequest private var hubs: FetchedResults<Hub>

    init(trip: Trip) {
        self.trip = trip

        _lists = FetchRequest(
            entity: List.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \List.createdAt, ascending: true)
            ],
            predicate: NSPredicate(format: "trip == %@", trip)
        )

        _hubs = FetchRequest(
            entity: Hub.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Hub.addedAt, ascending: true)
            ],
            predicate: NSPredicate(format: "trip == %@", trip)
        )
    }

    func createList(named: String) {
        let list = List(context: moc)
        list.name = named
        list.createdAt = Date.now
        list.trip = trip

        do {
            try moc.save()
        } catch {
            print(error)
            // TODO: Handle error
        }
    }

    private func addHub() {
        let hub = Hub(context: moc)
        hub.name = "Hotel Whatever"
        hub.checkIn = Date.now
        hub.checkOut = Date.now
        hub.trip = trip
        hub.addedAt = Date.now

        do {
            try moc.save()
        } catch {
            print(error)
            // TODO: handle error
        }
    }

    private func handleDelete(_ indexSet: IndexSet) {
        indexSet
            .map { hubs[$0] }
            .forEach { hub in
                moc.delete(hub)
            }

        do {
            try moc.save()
        } catch {
            print(error)
            // TODO: handle error
        }
    }

    var body: some View {
        SwiftUI.List {
            InfoSection(trip: trip)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .environment(\.editMode, editMode)
                .environment(\.managedObjectContext, moc)

            HubsSection(trip: trip)
                .listRowSeparator(.hidden)
                .environment(\.editMode, editMode)
                .environment(\.managedObjectContext, moc)

            ForEach(lists) { list in
                PoiListSection(list: list)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .environment(\.editMode, editMode)
                    .environment(\.managedObjectContext, moc)
            }

            CreateListSection { name in
                createList(named: name)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .environment(\.editMode, editMode)
            .padding()
        }

        .animation(.easeOut, value: lists.count)
        .transition(.asymmetric(insertion: .opacity, removal: .slide))

        .listStyle(.plain)
    }
}

struct TripSummary_Previews: PreviewProvider {
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

        let list = List(context: moc)
        list.name = "List section"

        let poi1 = PointOfInterest(context: moc)
        poi1.name = "Louvre"
        poi1.address = "Rue de Rivoli, 75001 Paris, France"
        poi1.thumbnail = "https://images.unsplash.com/photo-1585843149061-096a118a5ce7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzMTQxNzd8MHwxfHJhbmRvbXx8fHx8fHx8fDE2NTAwOTY3NTQ&ixlib=rb-1.2.1&q=80&w=200"
        poi1.blurhash = "LbD9eqf60KayNGjus:ay9Fj[-qj["

        let poi2 = PointOfInterest(context: moc)
        poi2.name = "Louvre"
        poi2.address = "Rue de Rivoli, 75001 Paris, France"
        poi2.thumbnail = "https://images.unsplash.com/photo-1585843149061-096a118a5ce7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzMTQxNzd8MHwxfHJhbmRvbXx8fHx8fHx8fDE2NTAwOTY3NTQ&ixlib=rb-1.2.1&q=80&w=200"
        poi2.blurhash = "LbD9eqf60KayNGjus:ay9Fj[-qj["

        let poi3 = PointOfInterest(context: moc)
        poi3.name = "Louvre"
        poi3.address = "Rue de Rivoli, 75001 Paris, France"
        poi3.thumbnail = "https://images.unsplash.com/photo-1585843149061-096a118a5ce7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzMTQxNzd8MHwxfHJhbmRvbXx8fHx8fHx8fDE2NTAwOTY3NTQ&ixlib=rb-1.2.1&q=80&w=200"
        poi3.blurhash = "LbD9eqf60KayNGjus:ay9Fj[-qj["

        list.items = NSOrderedSet(array: [
            poi1,
            poi2,
            poi3
        ])

        trip.lists = NSOrderedSet(array: [list])

        return NavigationView { TripSummary(trip: trip)
            .environment(\.managedObjectContext, moc)
        }
    }
}
