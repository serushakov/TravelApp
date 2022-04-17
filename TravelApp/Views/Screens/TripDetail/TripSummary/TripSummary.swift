//
//  TripSummary.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI

struct TripSummary: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    let trip: Trip
    @FetchRequest var lists: FetchedResults<List>

    init(trip: Trip) {
        self.trip = trip
        _lists = FetchRequest(
            entity: List.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \List.createdAt, ascending: true)
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
        let list = List(context: managedObjectContext)
        list.name = named
        list.trip = trip

        let poi1 = PointOfInterest(context: managedObjectContext)
        poi1.name = "Louvre"
        poi1.address = "Rue de Rivoli, 75001 Paris, France"
        poi1.thumbnail = "https://images.unsplash.com/photo-1585843149061-096a118a5ce7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzMTQxNzd8MHwxfHJhbmRvbXx8fHx8fHx8fDE2NTAwOTY3NTQ&ixlib=rb-1.2.1&q=80&w=200"
        poi1.blurhash = "LbD9eqf60KayNGjus:ay9Fj[-qj["
        poi1.addedAt = Date.now
        poi1.list = list

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
            // TODO: Handle error
        }
    }

    var body: some View {
        ScrollView {
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
            }.frame(height: 200)

            VStack(alignment: .leading) {
                Text(trip.destination!.name!)
                    .font(.largeTitle.bold())
                    .padding()

                ForEach(lists) { list in
                    ListSection(list: list)
                        .onTapGesture {}
                        .onLongPressGesture {
                            managedObjectContext.delete(list)
                            do {
                                try managedObjectContext.save()
                            } catch {
                                print(error)
                                // TODO: Handle error
                            }
                        }
                }

                CreateListSection { name in
                    createList(named: name)
                }.padding()
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                alignment: .topLeading
            )
            .background(.background)
        }
        .navigationTitle(trip.destination!.name!)
        .navigationBarTitleDisplayMode(.inline)
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
