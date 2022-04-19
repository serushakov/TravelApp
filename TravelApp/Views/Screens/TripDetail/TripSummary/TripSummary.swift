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
    let onBack: () -> Void

    @FetchRequest var lists: FetchedResults<List>
    @FetchRequest private var hubs: FetchedResults<Hub>

    init(trip: Trip, onBack: @escaping () -> Void) {
        self.trip = trip
        self.onBack = onBack

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

    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .named("scroll")).minY
    }

    private func getTitleOpacity(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)

        print(offset)

        return 1
    }

    // 2
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)

        // Image was pulled down
        if offset > 0 {
            return -offset
        } else {
            return -offset * 0.2
        }
    }

    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
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
        VStack {
            SwiftUI.List {
                GeometryReader { proxy in
                    VStack {
                        if let imageUrl = trip.image?.url {
                            BlurHashImage(url: URL(string: imageUrl)!, blurHash: trip.image!.blurHash, size: CGSize(width: 4, height: 3))
                        } else {
                            Image("download")
                        }
                    }
                    .frame(width: proxy.size.width, height: self.getHeightForHeaderImage(proxy))
                    .clipped()
                    .offset(x: 0, y: self.getOffsetForHeaderImage(proxy))
                }
                .frame(height: 200)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())

                Text(trip.destination!.name!)
                    .font(.largeTitle.bold())
                    .listRowSeparator(.hidden)

                HubsSection(trip: trip)
                    .environment(\.managedObjectContext, moc)
                    .listRowSeparator(.hidden)

                ForEach(lists) { list in
                    PoiListSection(list: list)
                        .environment(\.managedObjectContext, moc)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }

                CreateListSection { name in
                    createList(named: name)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .animation(.easeOut, value: lists.count)
            .transition(.slide)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(trip.destination!.name!)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Label("Trips", systemImage: "arrow.backward")
                        .labelStyle(.titleAndIcon)
                }
            }
            ToolbarItem {
                EditButton()
            }
        }
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

        return NavigationView { TripSummary(trip: trip) {}
            .environment(\.managedObjectContext, moc)
        }
    }
}
