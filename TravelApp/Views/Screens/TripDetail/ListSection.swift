//
//  ListSection.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 16.4.2022.
//

import SwiftUI

struct ListSection: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var list: List
    var isEditing: Bool

    @FetchRequest private var items: FetchedResults<PointOfInterest>

    init(list: List, isEditing: Bool) {
        self.list = list
        self.isEditing = isEditing

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

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
            // TODO: Handle error
        }
    }

    private func addItem() {
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
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(list.name!)
                    .font(.title2.bold())
                Spacer()
                Button {
                    if isEditing {
                        deleteSection()
                    } else {
                        addItem()
                    }
                } label: {
                    if isEditing {
                        Text("Delete")
                            .foregroundColor(.red)
                    } else {
                        Label("Add item to list", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .font(.title3)
                    }
                }
                .animation(.easeOut, value: isEditing)
                .transition(.opacity)
            }
            .padding(.horizontal)
            .padding(.top)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let items = list.items?.array as? [PointOfInterest] {
                        ForEach(items) { item in
                            DeletableItem(isEditing: isEditing, onDelete: {}) {
                                PoI(
                                    name: item.name!,
                                    address: item.address!,
                                    image: item.thumbnail!,
                                    blurHash: item.blurhash!
                                ).frame(width: UIScreen.main.bounds.width / 2.5)
                            }
                        }

                        if items.count == 0 {
                            Button {
                                addItem()
                            } label: {
                                AddItem(label: "Add new point of interest")
                                    .frame(width: UIScreen.main.bounds.width / 2.5)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
        }
    }
}

struct ListSection_Previews: PreviewProvider {
    static let moc = PersistenceController.preview.container.viewContext

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
            ListSection(list: list, isEditing: false)
            ListSection(list: list, isEditing: true)
        }.previewLayout(.device)
    }
}