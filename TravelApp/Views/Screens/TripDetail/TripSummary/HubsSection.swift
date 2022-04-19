import SwiftUI

struct HubsSection: View {
    @Environment(\.managedObjectContext) private var moc

    let trip: Trip

    @Environment(\.editMode) private var editMode
    @FetchRequest private var hubs: FetchedResults<Hub>

    init(trip: Trip) {
        self.trip = trip

        _hubs = FetchRequest(
            entity: Hub.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Hub.addedAt, ascending: true)
            ],
            predicate: NSPredicate(format: "trip == %@", trip)
        )
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
        Section {
            ListSectionHeader(title: "Hubs", onAdd: addHub)
                .padding(.horizontal)
                .padding(.bottom, 8)

            ForEach(hubs) { hub in
                Button {} label: {
                    HStack {
                        Text(hub.name!)
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }.padding(.trailing)
                }
                .listRowSeparator(.automatic)
                .padding(.leading)
            }
            .onDelete(perform: handleDelete)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}

struct Hubs_Previews: PreviewProvider {
    static let moc = PersistenceController.preview.container.viewContext

    static var previews: some View {
        let trip = Trip(context: moc)
        let hub = Hub(context: moc)
        hub.name = "Test"
        hub.trip = trip

        return SwiftUI.List {
            HubsSection(
                trip: trip
            )
        }
        .listStyle(.plain)
        .environment(\.managedObjectContext, moc)
        .previewLayout(.sizeThatFits)
    }
}
