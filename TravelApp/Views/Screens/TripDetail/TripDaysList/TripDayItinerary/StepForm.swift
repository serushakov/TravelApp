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

    let poi: PointOfInterest
    let trip: Trip
    let onFinished: () -> Void

    @State var arrival = Date.now
    @State var departure = Date.now

    func getLimit(for date: Date) -> Date {
        let startOfDay: Date = Calendar.current.startOfDay(for: date)
        let components = DateComponents(hour: 23, minute: 59, second: 59)

        return Calendar.current.date(byAdding: components, to: startOfDay) ?? date
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
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Text(poi.name!)
                }

                DatePicker("Arrival time", selection: $arrival, displayedComponents: .hourAndMinute)
                DatePicker("Leaving at", selection: $departure, in: arrival ... getLimit(for: arrival), displayedComponents: .hourAndMinute)
            }
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
