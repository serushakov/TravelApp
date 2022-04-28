//
//  TripEditForm.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.4.2022.
//

import SwiftUI

struct TripEditForm: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    let trip: Trip
    let onFinished: () -> Void

    @State var arrival: Date
    @State var departure: Date
    @State var arrivalPlace: PointOfInterest?
    @State var departurePlace: PointOfInterest?

    init(trip: Trip, onFinished: @escaping () -> Void) {
        self.trip = trip
        self.onFinished = onFinished

        _arrival = State(initialValue: trip.arrival ?? Date.now)
        _departure = State(initialValue: trip.departure ?? Date.now)
        _arrivalPlace = State(initialValue: trip.destination?.arrival)
        _departurePlace = State(initialValue: trip.destination?.departure)
    }

    func saveTrip() {
        trip.departure = departure
        trip.arrival = arrival

        let destination = trip.destination ?? Destination(context: managedObjectContext)
        destination.arrival = arrivalPlace
        destination.departure = departurePlace

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
            // TODO: handle error
        }
        onFinished()
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("When", selection: $arrival)
                    NavigationLink {
                        TravelPlacePicker(place: $arrivalPlace)
                    } label: {
                        HStack {
                            Text("To")
                            Spacer(minLength: 16)
                            Text(arrivalPlace?.name ?? "")
                        }
                    }
                } header: {
                    Label("Arrival", systemImage: "airplane.arrival")
                }
                .onChange(of: arrivalPlace) { value in
                    if departurePlace == nil {
                        departurePlace = value
                    }
                }

                Section {
                    DatePicker("When", selection: $departure, in: arrival ... Date.distantFuture)

                    NavigationLink {
                        TravelPlacePicker(place: $departurePlace)
                    } label: {
                        HStack {
                            Text("From")
                            Spacer(minLength: 16)
                            Text(departurePlace?.name ?? "")
                        }
                    }
                } header: {
                    Label("Departure", systemImage: "airplane.departure")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onFinished()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Save") {
                        saveTrip()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Edit trip details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// struct TripEditForm_Previews: PreviewProvider {
//    static var previews: some View {
//        TripEditForm()
//    }
// }
