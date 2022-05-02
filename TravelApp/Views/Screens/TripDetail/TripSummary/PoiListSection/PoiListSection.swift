//
//  ListSection.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 16.4.2022.
//

import SwiftUI

struct PoiListSection: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.editMode) private var editMode

    var list: List
    @State var showPoiAddition = false
    @State var showPoiDetail = false
    @State var poiDetail: PointOfInterest? = nil

    @FetchRequest private var items: FetchedResults<PointOfInterest>
    private var isEditing: Bool {
        editMode?.wrappedValue == EditMode.active
    }

    init(list: List) {
        self.list = list

        _items = FetchRequest(
            entity: PointOfInterest.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \PointOfInterest.addedAt, ascending: true)
            ],
            predicate: NSPredicate(format: "list == %@", list)
        )
    }

    private func deleteSection() {
        managedObjectContext.delete(list)
        print("Delete")

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
            // TODO: Handle error
        }
    }

    private func onAddItemClick() {
        showPoiAddition = true
    }

    private func handleNewPoi(_ poi: PointOfInterest) {
        poi.list = list

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        showPoiAddition = false
    }

    private func deleteItem(poi: PointOfInterest) {
        managedObjectContext.delete(poi)

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }

    var body: some View {
        if let name = list.name {
            Section {
                ListSectionHeader(
                    title: name,
                    onAdd: onAddItemClick,
                    onDelete: deleteSection
                )
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            Button {
                                poiDetail = item
                            } label: {
                                EditableItem(onDelete: {
                                    deleteItem(poi: item)
                                }) {
                                    PoI(
                                        name: item.name!,
                                        address: item.address!,
                                        image: item.thumbnail,
                                        blurHash: item.blurhash
                                    ).frame(width: UIScreen.main.bounds.width / 2.3)
                                }
                                .transition(.scale)
                                .environment(\.editMode, editMode)
                            }.buttonStyle(.plain)
                        }

                        if items.count == 0 {
                            Button {
                                onAddItemClick()
                            } label: {
                                AddItem(label: "Add new point of interest")
                                    .frame(width: UIScreen.main.bounds.width / 2.3)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                }
                .animation(.easeOut, value: list.items?.count)
                .transition(.slide)
            }
            .sheet(isPresented: $showPoiAddition) {
                PoiSearch(trip: list.trip!) { handleNewPoi($0) } onClose: {
                    showPoiAddition = false
                }
            }
            .sheet(item: $poiDetail) { item in
                PoiDetails(poi: item) {
                    poiDetail = nil
                }
            }
        }
    }
}

struct ListSection_Previews: PreviewProvider {
    static let moc = PersistenceController.preview.container.viewContext
    @State static var editMode = EditMode.active

    static var previews: some View {
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

        return VStack {
            PoiListSection(list: list)
            PoiListSection(list: list)
                .environment(\.editMode, $editMode)
        }.previewLayout(.device)
    }
}
