//
//  InfoSection.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 19.4.2022.
//

import SwiftUI

struct InfoSection: View {
    let trip: Trip
    var body: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                InfoItem(type: .arrival(trip.arrival ?? Date.now))
                InfoItem(type: .departure(trip.departure ?? Date.now))
                InfoItem(type: .weather(.cloudSun, text: "10-15℃"))
            }.padding()
        }
    }
}

// struct InfoSection_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoSection()
//    }
// }
