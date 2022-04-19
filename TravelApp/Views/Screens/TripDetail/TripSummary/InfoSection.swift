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
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(0 ... 2, id: \.self) { _ in
                Rectangle()
                    .foregroundColor(.gray)
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(8)
            }
        }.padding()
    }
}

// struct InfoSection_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoSection()
//    }
// }
