//
//  StepForm.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

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

    init(day: Date, poi: PointOfInterest, prevStep: StepDescriptor, trip: Trip, onFinished: @escaping () -> Void) {
        self.day = day
        self.poi = poi
        self.prevStep = prevStep
        self.trip = trip
        self.onFinished = onFinished

        let arrival = prevStep.departure!.advanced(by: 30 * 60)
        _arrival = State(wrappedValue: arrival)
        _departure = State(wrappedValue: arrival.advanced(by: 60 * 60))
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
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .background(.background)
                            .cornerRadius(8)

                        StepDivider(walkEstimate: .loaded(25 * 60), busEstimate: .loaded(10 * 60)) // TODO: Add actual values

                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            HStack {
                                Text(poi.name!)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .tint(Color.white)
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(8)
                    }

                    .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)

                DatePicker("Arrival time", selection: $arrival, in: prevStep.departure! ... arrival.getDayEnd(), displayedComponents: .hourAndMinute)
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
