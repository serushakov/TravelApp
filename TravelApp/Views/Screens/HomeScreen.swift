//
//  HomeView.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 27.3.2022.
//

import SwiftUI

struct HomeScreen: View {
    let trips = [
        "Paris",
        "Helsinki",
        "Amsterdam",
        "A very very very very long name",
    ]

    var body: some View {
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
                Button(action: {}) {
                    Label("Add trip", systemImage: "plus")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
