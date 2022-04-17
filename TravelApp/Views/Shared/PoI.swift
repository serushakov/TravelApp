//
//  PoI.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 16.4.2022.
//

import SwiftUI

struct PoI: View {
    let name: String
    let address: String
    let image: String
    let blurHash: String

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                BlurHashImage(url: URL(string: image)!, blurHash: blurHash, size: CGSize(width: 4, height: 3))
                    .frame(minHeight: 0)
                    .clipped()
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.footnote.bold())
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    Text(address)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                .padding(8)
            }
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .background(.background)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

struct PoI_Previews: PreviewProvider {
    static var previews: some View {
        PoI(
            name: "Louvre",
            address: "Who TF Knows",
            image: "https://images.unsplash.com/photo-1585843149061-096a118a5ce7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzMTQxNzd8MHwxfHJhbmRvbXx8fHx8fHx8fDE2NTAwOTY3NTQ&ixlib=rb-1.2.1&q=80&w=200",
            blurHash: "LbD9eqf60KayNGjus:ay9Fj[-qj["
        )
        .padding()
        .frame(width: 200)
        .previewLayout(.sizeThatFits)
    }
}
