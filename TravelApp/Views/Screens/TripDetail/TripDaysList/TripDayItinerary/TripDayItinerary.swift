//
//  TripDayItinerary.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.4.2022.
//

import Foundation
import MapKit
import SwiftUI

struct Route {
    let from: CLLocationCoordinate2D
    let to: CLLocationCoordinate2D
}

struct TravelEstimate {
    let onFoot: TimeInterval
    let publicTransport: TimeInterval
}

struct StepWithDivider: View {
    let step: StepDescriptor
    let prevStep: StepDescriptor

    let onStepPress: () -> Void

    @ObservedObject var estimateProvider: TravelEstimateProvider

    init(step: StepDescriptor, prevStep: StepDescriptor, onStepPress: @escaping () -> Void) {
        self.step = step
        self.prevStep = prevStep
        self.onStepPress = onStepPress
        estimateProvider = TravelEstimateProvider(from: prevStep.location, to: step.location)
    }

    var body: some View {
        Group {
            StepDivider(walkEstimate: estimateProvider.walkEstimate, busEstimate: estimateProvider.busEstimate)
            Button(action: onStepPress) {
                StepView(name: step.title, ordinal: step.ordinal!, startTime: step.arrival!, endTime: step.departure!)
            }
        }
    }
}

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
        guard let arrival = trip.arrival else {
            return nil
        }

        print("daydaydaydaydaydya", arrival, day)

        let isArrivalDay = arrival.isSameDay(as: day)

        if isArrivalDay, let arrivalPlace = trip.destination?.arrival, let arrivalDate = trip.arrival {
            return StepDescriptor(
                type: .arrival,
                title: arrivalPlace.name!,
                location: CLLocationCoordinate2D(latitude: arrivalPlace.latitude, longitude: arrivalPlace.longitude),
                departure: arrivalDate
            )
        }

        if let hub = hubs.first {
            return StepDescriptor(
                type: .hub,
                title: hub.name!,
                location: CLLocationCoordinate2D(latitude: hub.latitude, longitude: hub.longitude)
            )
        }

        return nil
    }

    var finishStep: StepDescriptor? {
        guard let departure = trip.departure else {
            return nil
        }

        let isDepartureDay = departure.isSameDay(as: day)

        if isDepartureDay, let departurePlace = trip.destination?.departure, let departureDate = trip.departure {
            return StepDescriptor(
                type: .departure,
                title: departurePlace.name!,
                location: CLLocationCoordinate2D(latitude: departurePlace.latitude, longitude: departurePlace.longitude),
                departure: departureDate
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

        if let finishStep = finishStep {
            steps.append(finishStep)
        }

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
            return AnyView(HubStep(name: step.title))
        default:
            return AnyView(EmptyView())
        }
    }

    var finishStepView: some View {
        guard let step = finishStep else { return AnyView(EmptyView()) }

        return AnyView(Group {
            StepDivider(walkEstimate: .none, busEstimate: .none)
            TravelStep(type: .departure, name: step.title, time: step.departure!)
        })
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
                        StepWithDivider(
                            step: StepDescriptor(fromStep: step, ordinal: index + 1)!,
                            prevStep: allSteps[index]
                        ) {
                            editedStep = step
                        }
                    }
                    StepDivider(walkEstimate: .none, busEstimate: .none)
                    Button {
                        showStepCreation = true
                    } label: {
                        AddStepButton()
                    }
                    finishStepView
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
