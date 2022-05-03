//
//  ElevatedBackground.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 23.4.2022.
//

import SwiftUI

/**
 View that will pick best background color for card content, so that it looks best on
 light and dark modes
 */
struct ElevatedBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        switch colorScheme {
        case .light:
            Rectangle()
                .foregroundColor(.clear)
                .background(.background)
        case .dark:
            Rectangle()
                .foregroundColor(.clear)
                .background(.regularMaterial)
        @unknown default:
            Rectangle()
                .foregroundColor(.clear)
                .background(.background)
        }
    }
}

struct ElevatedBackground_Previews: PreviewProvider {
    static var previews: some View {
        ElevatedBackground()
    }
}
