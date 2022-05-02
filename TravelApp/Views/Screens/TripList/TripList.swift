//
//  HomeView.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 27.3.2022.
//

import MapKit
import SwiftUI

struct TripList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.editMode) private var editMode
    @State var showTripAddition = false

    @FetchRequest(
        entity: Trip.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Trip.createdAt, ascending: true)
        ]
    ) var trips: FetchedResults<Trip>

    func deleteTrip(_ trip: Trip) {
        withAnimation {
            managedObjectContext.delete(trip)
        }
        do {
            try managedObjectContext.save()
            if trips.count == 0 {
                editMode?.wrappedValue = EditMode.inactive
            }
        } catch {}
    }

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()], alignment: .trailing) {
                        ForEach(trips) { trip in
                            NavigationLink {
                                TripDetail(trip: trip)
                            } label: {
                                EditableItem(onDelete: {
                                    deleteTrip(trip)
                                }) {
                                    TripItem(
                                        city: (trip.destination?.name!)!,
                                        country: trip.destination?.country ?? "",
                                        image: trip.image?.url,
                                        blurHash: trip.image?.blurHash
                                    )
                                }
                            }
                        }

                        Button(action: {
                            showTripAddition = true
                            editMode?.wrappedValue = EditMode.inactive
                        }) {
                            AddItem(label: "New trip")
                        }
                    }
                    .animation(.easeOut, value: trips.count)
                    .transition(.slide)
                    .padding(.horizontal)
                }
                .navigationTitle("Trips")
                .toolbar {
                    ToolbarItemGroup {
                        if trips.count > 0 {
                            EditButton()
                        }
                    }
                }
            }
            .sheet(isPresented: $showTripAddition) {
                TripCreation {
                    showTripAddition = false
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        TripList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
