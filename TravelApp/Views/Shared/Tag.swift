//
//  Tag.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 9.4.2022.
//

import SwiftUI

struct Tag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 8) {
            Tag(text: "Tag", color: Color.green)
            Tag(text: "Tag", color: Color.blue)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
