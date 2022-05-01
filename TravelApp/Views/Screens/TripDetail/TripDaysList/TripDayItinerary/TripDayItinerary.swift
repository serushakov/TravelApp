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
    @State var editedStep: Step? = nil

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
            sortDescriptors: [NSSortDescriptor(keyPath: \Step.visitStart, ascending: true)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "trip == %@", trip),
                NSPredicate(format: "(visitStart >= %@) AND (visitEnd <= %@)", day.getDayStart() as NSDate, day.getDayEnd() as NSDate),
            ])
        )
    }

    var startStep: StepDescriptor? {
        guard let arrival = trip.arrival, let departure = trip.departure else {
            return nil
        }

        let isArrivalDay = arrival.isSameDay(as: day)
        let isDepartureDay = departure.isSameDay(as: day)

        if isArrivalDay, let arrivalPlace = trip.destination?.arrival, let arrivalDate = trip.arrival {
            return StepDescriptor(
                type: .arrival,
                title: arrivalPlace.name!,
                location: CLLocationCoordinate2D(latitude: arrivalPlace.latitude, longitude: arrivalPlace.longitude),
                departure: arrivalDate
            )
        }

        if isDepartureDay, let departurePlace = trip.destination?.departure, let departureDate = trip.departure {
            return StepDescriptor(
                type: .departure,
                title: departurePlace.name!,
                location: CLLocationCoordinate2D(latitude: departurePlace.latitude, longitude: departurePlace.longitude),
                departure: departureDate
            )
        }

        if let hub = hubs.first {
            return StepDescriptor(
                type: .hub,
                title: hub.name!,
                location: CLLocationCoordinate2D(latitude: hub.latitude, longitude: hub.longitude),
                departure: Date.now // TODO: Use StartStep here
            )
        }

        return nil
    }

    var allSteps: [StepDescriptor] {
        guard let startStep = startStep else {
            return []
        }

        var steps = [startStep]

        steps.append(contentsOf: self.steps.enumerated().compactMap {
            StepDescriptor(fromStep: $1, ordinal: $0 + 1)
        })

        return steps
    }

    var startStepView: some View {
        guard let step = startStep else { return AnyView(EmptyView()) }

        switch step.type {
        case .arrival:
            return AnyView(
                TravelStep(type: .arrival, name: step.title, time: step.departure!)
            )
        case .hub:
            return AnyView(HubStep(
                name: step.title,
                time: step.departure!
            ))
        default:
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ItineraryMap(steps: allSteps)
                    .cornerRadius(8)
                    .frame(height: 300)

                Text(day, format: Date.FormatStyle().day().month(.wide))
                    .font(.title.bold())
                    .onAppear {
                        print(steps)
                    }

                VStack(alignment: .leading, spacing: 0) {
                    startStepView

                    ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                        Group {
                            StepDivider(walkEstimate: .loaded(25 * 60), busEstimate: .loaded(10 * 60))
                            Button {
                                editedStep = step
                            } label: {
                                StepView(name: step.poi!.name!, ordinal: index + 1, startTime: step.visitStart!, endTime: step.visitEnd!)
                            }
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
        .sheet(item: $editedStep) { item in
            Button("Delete", role: .destructive) {
                managedObjectContext.delete(item)
                do {
                    try managedObjectContext.save()
                } catch {}
                editedStep = nil
            }
        }
        .sheet(isPresented: $showStepCreation) {
            if let startStep = startStep {
                let lastStep = steps.last != nil ? StepDescriptor(fromStep: steps.last!, ordinal: steps.count - 1) : nil

                StepCreation(day: day, trip: trip, prevStep: lastStep ?? startStep) {
                    showStepCreation = false
                }
            } else {
                EmptyView()
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

    static func getDayStart(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    func getDayStart() -> Date {
        return Date.getDayStart(for: self)
    }

    static func getDayEnd(for date: Date) -> Date {
        let startOfDay: Date = date.getDayStart()
        let components = DateComponents(hour: 23, minute: 59, second: 59)

        return Calendar.current.date(byAdding: components, to: startOfDay) ?? date
    }

    func getDayEnd() -> Date {
        return Date.getDayEnd(for: self)
    }
}
