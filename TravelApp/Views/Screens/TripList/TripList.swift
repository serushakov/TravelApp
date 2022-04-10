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
    let trips = [
        "Paris",
        "Helsinki",
        "Amsterdam",
        "A very very very very long name",
    ]
    @State var showTripAddition = false

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(trips, id: \.self) { name in
                            TripItem(city: name, country: "France") {}
                        }
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Trips")
                .toolbar {
                    Button(action: {
                        showTripAddition = true
                    }) {
                        Label("Add trip", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showTripAddition) {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 40, height: 6)
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.top, 8)

                    HStack(alignment: .center) {
                        Text("New trip")
                            .font(.title.bold())
                        Spacer()
                        Button(action: {
                            showTripAddition = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    TripCreation(isVisible: showTripAddition)
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
