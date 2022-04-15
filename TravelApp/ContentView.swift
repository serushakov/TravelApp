//
//  ContentView.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 15.4.2022.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTrip: Trip? = nil
    @Environment(\.managedObjectContext) var managedObjectContext

    func selectTrip(trip: Trip?) {
        withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
            selectedTrip = trip
        }
    }

    var body: some View {
        ZStack {
            TripList { trip in

                selectTrip(trip: trip)
            }
            .environment(\.managedObjectContext, managedObjectContext)
            .scaleEffect(selectedTrip == nil ? 1 : 0.9)
            .transition(.scale(scale: 0.9))

            if let trip = selectedTrip {
                TripDetail(trip: trip) {
                    selectTrip(trip: nil)
                }
                .frame(maxHeight: .infinity)
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .id(trip.id)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxHeight: .infinity)
    }
}
