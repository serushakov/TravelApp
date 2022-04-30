//
//  TripDayItinerary.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.4.2022.
//

import Foundation
import MapKit
import SwiftUI

struct TripDayItinerary: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var trip: Trip
    var day: Date

    @FetchRequest private var hubs: FetchedResults<Hub>
    @FetchRequest private var steps: FetchedResults<Step>

    @State var showStepCreation = false

    init(trip: Trip, day: Date) {
        self.trip = trip
        self.day = day

        let tripPredicate = NSPredicate(format: "trip == %@", trip)
        let datePredicate = NSPredicate(format: "(checkIn <= %@) AND (checkOut >= %@)", day as NSDate, day as NSDate)

        _hubs = FetchRequest(
            entity: Hub.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Hub.addedAt, ascending: true),
            ],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [tripPredicate, datePredicate])
        )

        _steps = FetchRequest(
            entity: Step.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Step.visitStart, ascending: true)]
        )
    }

    var mapRect: MKMapRect {
        let coordinates = hubs.map { hub in
            CLLocationCoordinate2D(latitude: hub.latitude, longitude: hub.longitude)
        }

        let rects = coordinates.lazy.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
        let rect = rects.reduce(MKMapRect.null) { $0.union($1) }

        return rect
    }

    var startStep: some View {
        guard let arrival = trip.arrival else { return AnyView(EmptyView()) }

        let isArrivalDay = arrival.isSameDay(as: day)

        if isArrivalDay, let arrivalPlace = trip.destination?.arrival?.name {
            return AnyView(
                TravelStep(type: .arrival, name: arrivalPlace, time: arrival)
            )
        } else if let hub = hubs.first {
            return AnyView(HubStep(
                name: hub.name!,
                time: Date.now
            ))
        }
        return AnyView(EmptyView())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Map(mapRect: Binding.constant(mapRect))
                    .edgesIgnoringSafeArea(.top)
                    .cornerRadius(8)
                    .frame(height: 300)

                Text(day, format: Date.FormatStyle().day().month(.wide))
                    .font(.title.bold())

                VStack(alignment: .leading, spacing: 0) {
                    startStep

                    ForEach(steps) { step in
                        Group {
                            StepDivider(walkEstimate: .loaded(25 * 60), busEstimate: .loaded(10 * 60))
                            StepView(name: step.poi!.name!, startTime: step.visitStart!, endTime: step.visitEnd!)
                        }
                    }
                    StepDivider(walkEstimate: .none, busEstimate: .none)
                    Button {
                        showStepCreation = true
                    } label: {
                        AddStepButton()
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showStepCreation) {
            StepCreation(trip: trip) {
                showStepCreation = false
            }
        }
    }
}

// struct TripDayItinerary_Previews: PreviewProvider {
//    static var previews: some View {
//        TripDayItinerary()
//    }
// }

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

extension Date {
    func isSameDay(as date: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: self, to: date)

        return diff.day == 0
    }
}
