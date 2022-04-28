//
//  Tag.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 9.4.2022.
//

import SwiftUI

struct Tag<Content>: View where Content: View {
    let content: Content
    let color: Color

    init(_ text: String, color: Color) where Content == Text {
        self.color = color
        self.content = Text(text)
    }

    init(color: Color, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.color = color
    }

    var body: some View {
        content
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
            Tag("Tag", color: Color.green)
            Tag("Tag", color: Color.blue)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
