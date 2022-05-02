//
//  AddItemSquare.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 16.4.2022.
//

import SwiftUI

/**
 Universal AddItem button that can be used in lists and grids
 */
struct AddItem: View {
    let label: String
    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: proxy.size.width)
                        .foregroundColor(Color.blue.opacity(0.12))
                }
            }

            Label(label, systemImage: "plus.circle.fill")
                .foregroundColor(.blue)
                .labelStyle(.iconOnly)
                .font(.largeTitle)
        }.aspectRatio(1, contentMode: .fill)
    }
}

struct AddItemSquare_Previews: PreviewProvider {
    static var previews: some View {
        AddItem(label: "Add item")
            .frame(width: 200)
            .previewLayout(.sizeThatFits)
    }
}
