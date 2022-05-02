//
//  StepForm.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import MapKit
import SwiftUI

struct StepForm: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    let day: Date
    let poi: PointOfInterest
    let prevStep: StepDescriptor
    let trip: Trip
    let onFinished: () -> Void

    @State var arrival: Date
    @State var departure: Date

    @ObservedObject var estimateProvider: TravelEstimateProvider

    init(day: Date, poi: PointOfInterest, prevStep: StepDescriptor, trip: Trip, onFinished: @escaping () -> Void) {
        self.day = day
        self.poi = poi
        self.prevStep = prevStep
        self.trip = trip
        self.onFinished = onFinished

        let dayStart = day.getDayStart().advanced(by: 9 * 60 * 60)
        let arrival = prevStep.departure == nil ? dayStart : prevStep.departure!.advanced(by: 30 * 60)
        _arrival = State(wrappedValue: arrival)
        _departure = State(wrappedValue: arrival.advanced(by: 60 * 60))

        estimateProvider = TravelEstimateProvider(from: prevStep.location, to: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude))
    }

    func createStep() {
        let step = Step(context: managedObjectContext)

        step.poi = poi
        step.trip = trip
        step.visitStart = arrival
        step.visitEnd = departure

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
            // TODO: Handle error
        }

        onFinished()
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(prevStep.title)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .stretch(alignment: .leading)
                            .background(.background)
                            .cornerRadius(8)

                        StepDivider(walkEstimate: estimateProvider.walkEstimate, busEstimate: estimateProvider.busEstimate)

                        HStack {
                            Text(poi.name!)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .stretch(alignment: .leading)
                        .background(.white)
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(8)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }

                    .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)

                DatePicker("Arrival time", selection: $arrival, in: (prevStep.departure ?? day.getDayStart()) ... arrival.getDayEnd(), displayedComponents: .hourAndMinute)
                DatePicker("Leaving at", selection: $departure, in: arrival ... arrival.getDayEnd(), displayedComponents: .hourAndMinute)
            }
            .background(.background)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Add to itinerary") {
                    createStep()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// struct StepForm_Previews: PreviewProvider {
//    static var previews: some View {
//        StepForm()
//    }
// }

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
