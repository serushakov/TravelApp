//
//  StepCreation.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import SwiftUI

struct StepCreation: View {
    let trip: Trip
    let onFinished: () -> Void

    @FetchRequest private var lists: FetchedResults<List>

    init(trip: Trip, onFinished: @escaping () -> Void) {
        self.trip = trip
        self.onFinished = onFinished

        _lists = FetchRequest(
            entity: List.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \List.createdAt, ascending: true),
            ],
            predicate: NSPredicate(format: "trip == %@", trip)
        )
    }

    var body: some View {
        NavigationView {
            SwiftUI.List {
                ForEach(lists) { list in
                    Section(list.name!) {
                        ForEach(list.mutableOrderedSetValue(forKey: "items").array as! [PointOfInterest]) { item in
                            NavigationLink {
                                StepForm(poi: item, trip: trip, onFinished: onFinished)
                            } label: {
                                Text(item.name!)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New step")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel", action: onFinished)
            }
        }
    }
}

// struct StepCreation_Previews: PreviewProvider {
//    static var previews: some View {
//        StepCreation {}
//    }
// }
