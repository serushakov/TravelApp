//
//  HomeView.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 27.3.2022.
//

import BottomSheet
import MapKit
import SwiftUI

public enum BottomSheetPositionTripList: CGFloat, CaseIterable {
    case top = 0.975, hidden = 0
}

struct TripList: View {
    let trips = [
        "Paris",
        "Helsinki",
        "Amsterdam",
        "A very very very very long name",
    ]
    @State var bottomSheetPosition: BottomSheetPositionTripList = .hidden

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(trips, id: \.self) { name in
                            TripItem(city: name, country: "France")
                        }
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Trips")
                .toolbar {
                    Button(action: {
                        bottomSheetPosition = .top
                    }) {
                            Label("Add trip", systemImage: "plus")
                    }
                }

            }.bottomSheet(
                bottomSheetPosition: $bottomSheetPosition,
                options: [
                    .showCloseButton {
                        bottomSheetPosition = .hidden
                    },
                    .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: -2),
                    .swipeToDismiss,
                    .noBottomPosition,
                    .animation(.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 1)),

                ], title: "New trip") {
                    TripCreation(isVisible: bottomSheetPosition == .top)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        TripList()
    }
}
