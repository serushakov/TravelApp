//
//  TravelStep.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import SwiftUI

enum TravelType {
    case arrival
    case departure
}

struct TravelStep: View {
    let type: TravelType
    let name: String
    let time: Date

    var iconName: String {
        switch type {
        case .arrival:
            return "airplane.arrival"
        case .departure:
            return "airplane.departure"
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: iconName)
                .font(.callout)
                .foregroundColor(.blue)
                .padding(7)
                .background(
                    Circle()
                        .stroke(.blue, lineWidth: 2.5)
                )
                .padding(.horizontal, 2)

            VStack(alignment: .leading) {
                Text(name)
                    .foregroundColor(.blue)
                Text(time, format: Date.FormatStyle().hour().minute())
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TravelStep_Previews: PreviewProvider {
    static var previews: some View {
        TravelStep(
            type: .arrival, name: "Airport", time: Date.now
        )
        .frame(width: 200)
        .previewLayout(.sizeThatFits)
    }
}
