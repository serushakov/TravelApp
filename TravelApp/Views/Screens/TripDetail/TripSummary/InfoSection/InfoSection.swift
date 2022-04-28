//
//  InfoSection.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 19.4.2022.
//

import SwiftUI



struct InfoSection: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.editMode) private var editMode

    let trip: Trip

    @State var showEdit = false

    private func formatDate(_ date: Date) -> String {
        return date
            .formatted(Date.FormatStyle().month().day(.defaultDigits))
    }

    var body: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                EditableItem(type: .edit) {
                    InfoItem(type: .arrival(formatDate(trip.arrival ?? Date.now)))

                } onEdit: {
                    showEdit = true
                }

                EditableItem(type: .edit) {
                    InfoItem(type: .departure(formatDate(trip.departure ?? Date.now)))
                } onEdit: {
                    showEdit = true
                }

                InfoItem(type: .weather(.cloudSun, text: "10-15℃"))
            }.padding()
        }
        .sheet(isPresented: $showEdit) {
            TripEditForm(trip: trip) { showEdit = false }
                .environment(\.managedObjectContext, moc)
        }
    }
}

// struct InfoSection_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoSection()
//    }
// }
