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
    @State private var scale: CGFloat = 1
    @State private var xButtonScale: CGFloat = 0

    @FetchRequest(
        entity: Trip.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Trip.createdAt, ascending: true)
        ]
    ) var trips: FetchedResults<Trip>
    @State var showTripAddition = false

    func deleteTrip(_ trip: Trip) {
        managedObjectContext.delete(trip)
        do {
            try managedObjectContext.save()
        } catch {}
    }

    func toggleEditMode() {
        isEditing.toggle()
        scale = isEditing ? 0.9 : 1
        xButtonScale = isEditing ? 1 : 0
    }

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()], alignment: .trailing) {
                        ForEach(trips, id: \.self) { trip in
                            ZStack(alignment: .topLeading) {
                                Button(action: {}) {
                                    TripItem(city: (trip.destination?.name!)!, country: trip.destination?.country ?? "")
                                }

                                if isEditing {
                                    DeleteItemButton {
                                        withAnimation { deleteTrip(trip) }
                                    }
                                    .offset(x: -12, y: -12)
                                    .transition(.asymmetric(insertion: .scale(scale: 0, anchor: UnitPoint.topLeading), removal: .opacity))
                                    .zIndex(1)
                                }
                            }
                            .scaleEffect(scale)
                            .animation(.spring(), value: scale)
                            .transition(.scale)
                        }

                        Button(action: {
                            showTripAddition = true
                        }) {
                            ZStack(alignment: .center) {
                                GeometryReader { proxy in
                                    ZStack(alignment: .center) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .frame(width: proxy.size.width, height: proxy.size.width)
                                            .foregroundColor(Color.blue.opacity(0.12))
                                    }
                                }

                                Label("Add new trip", systemImage: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .labelStyle(.iconOnly)
                                    .font(.largeTitle)
                            }
                        }.aspectRatio(1, contentMode: .fill)
                    }.padding(.horizontal)
                }
                .navigationTitle("Trips")
                .toolbar {
                    Button(action: {
                        withAnimation {
                            toggleEditMode()
                        }
                    }) {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
            }

            .sheet(isPresented: $showTripAddition) {
                VStack(spacing: 0) {
                    SheetHeader(title: "New trip") {
                        showTripAddition = false
                    }

                    TripCreation(isVisible: showTripAddition) { trip in
                        print(trip)
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
        TripList()
    }
}
