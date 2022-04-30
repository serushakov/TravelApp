//
//  View.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.4.2022.
//

import SwiftUI

extension View {
    func stretch() -> some View {
        return self.frame(minWidth: 0, maxWidth: .infinity)
    }

    func stretch(alignment: Alignment) -> some View {
        return self.frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
    }

    func square() -> some View {
        return self.aspectRatio(1, contentMode: .fill)
    }
}
