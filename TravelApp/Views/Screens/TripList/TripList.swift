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
    @State private var isEditing = false

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
                toggleEditMode(false)
            }
        } catch {}
    }

    func toggleEditMode(_ value: Bool? = nil) {
        if value != nil {
            isEditing = value!
        } else {
            isEditing.toggle()
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()], alignment: .trailing) {
                        ForEach(trips) { trip in
                            DeletableItem(isEditing: isEditing, onDelete: {
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
                            toggleEditMode(false)
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
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if trips.count > 0 {
                            Button(action: {
                                withAnimation {
                                    toggleEditMode()
                                }
                            }) {
                                Text(isEditing ? "Done" : "Edit")
                            }
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
