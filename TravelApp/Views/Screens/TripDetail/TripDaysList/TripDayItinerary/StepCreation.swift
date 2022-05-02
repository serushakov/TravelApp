//
//  StepCreation.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import SwiftUI

struct StepCreation: View {
    let day: Date
    let trip: Trip
    let prevStep: StepDescriptor
    let onFinished: () -> Void

    @FetchRequest private var lists: FetchedResults<List>

    init(day: Date, trip: Trip, prevStep: StepDescriptor, onFinished: @escaping () -> Void) {
        self.day = day
        self.trip = trip
        self.prevStep = prevStep
        self.onFinished = onFinished

        _lists = FetchRequest(
            entity: List.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \List.createdAt, ascending: true),
            ],
            predicate: NSPredicate(format: "trip == %@", trip)
        )
    }

    func getPois(of list: List) -> [PointOfInterest] {
        let array = list.mutableOrderedSetValue(forKey: "items").array

        return array as! [PointOfInterest]
    }

    var body: some View {
        NavigationView {
            SwiftUI.List {
                ForEach(lists) { list in
                    Section(list.name!) {
                        ForEach(getPois(of: list)) { element in
                            NavigationLink {
                                StepForm(
                                    day: day,
                                    poi: element,
                                    prevStep: prevStep,
                                    trip: trip,
                                    onFinished: onFinished
                                )
                            } label: {
                                Text(element.name!)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel", action: onFinished)
                }
            }
        }
    }
}

// struct StepCreation_Previews: PreviewProvider {
//    static var previews: some View {
//        StepCreation {}
//    }
// }
