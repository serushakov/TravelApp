//
//  StepView.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import SwiftUI

struct StepView: View {
    let name: String
    let startTime: Date
    let endTime: Date

    private let formatter = DateComponentsFormatter()

    var body: some View {
        HStack {
            Image(systemName: "house.circle")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding(.vertical, -2)
            VStack(alignment: .leading) {
                Text(name)
                    .foregroundColor(.blue)
                HStack {
                    Text(startTime, format: Date.FormatStyle().hour().minute())
                    Text("-")
                    Text(endTime, format: Date.FormatStyle().hour().minute())
                    Text(formatter.string(from: startTime.distance(to: endTime))!)
                }
                .foregroundColor(.secondary)
                .font(.caption)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct StepView_Previews: PreviewProvider {
    static var previews: some View {
        let interval: TimeInterval = 60 * 60

        StepView(
            name: "Louvre", startTime: Date.now, endTime: Date.now.advanced(by: interval)
        )
        .frame(width: 200)
        .previewLayout(.sizeThatFits)
    }
}
