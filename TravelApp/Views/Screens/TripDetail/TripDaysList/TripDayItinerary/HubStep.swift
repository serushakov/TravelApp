//
//  HubStep.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import SwiftUI

struct HubStep: View {
    let name: String
    let time: Date

    var body: some View {
        HStack {
            Image(systemName: "house.circle")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding(.vertical, -2)
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

struct HubStep_Previews: PreviewProvider {
    static var previews: some View {
        HubStep(
            name: "Hotel Whatever",
            time: Date.now
        )
        .frame(width: 200)
        .previewLayout(.sizeThatFits)
    }
}
