//
//  HomeView.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 27.3.2022.
//

import BottomSheet
import MapKit
import SwiftUI

struct TripList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.editMode) private var editMode

    var onTripSelect: (Trip) -> Void

    @FetchRequest(
        entity: Trip.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Trip.createdAt, ascending: true)
        ]
    ) var trips: FetchedResults<Trip>
    @State var showTripAddition = false

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
                            DeletableItem(onDelete: {
                                deleteTrip(trip)
                            }) {
                                Button {
                                    onTripSelect(trip)
                                } label: {
                                    TripItem(
                                        city: (trip.destination?.name!)!,
                                        country: trip.destination?.country ?? "",
                                        image: trip.image?.url,
                                        blurHash: trip.image?.blurHash
                                    )
                                }.transition(.scale)
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
                VStack(spacing: 0) {
                    SheetHeader(title: "New trip") {
                        showTripAddition = false
                    }

                    TripCreation(isVisible: showTripAddition) { _ in
                        showTripAddition = false
                    }
                    .environment(\.managedObjectContext, managedObjectContext)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        TripList { _ in }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
