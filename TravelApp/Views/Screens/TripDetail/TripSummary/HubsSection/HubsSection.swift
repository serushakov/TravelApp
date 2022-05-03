import SwiftUI

struct HubsSection: View {
    @Environment(\.managedObjectContext) private var moc

    let trip: Trip

    @State var showHubAddition = false
    @State var hubDetail: Hub? = nil
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

    private func addHub(_ hub: Hub) {
        showHubAddition = false
        hub.trip = trip

        do {
            try moc.save()
        } catch {
            print(error)
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
            ListSectionHeader(title: "Hotels or stays") { showHubAddition = true }
                .padding(.horizontal)
                .padding(.bottom, 8)

            ForEach(hubs) { hub in
                Button {
                    hubDetail = hub
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(hub.name!)
                            Text(hub.address ?? "")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }.padding(.trailing)
                }
                .listRowSeparator(.visible)
                .padding(.leading)
            }
            .onDelete(perform: handleDelete)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .sheet(isPresented: $showHubAddition) {
            HubSearch(trip: trip, onHubPicked: addHub) { showHubAddition = false }
                .environment(\.managedObjectContext, moc)
        }
        .sheet(item: $hubDetail) { hub in
            HubDetails(hub: hub) {
                hubDetail = nil
            }
        }
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
