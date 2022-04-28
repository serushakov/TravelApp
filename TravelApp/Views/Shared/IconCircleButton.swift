//
//  DeleteItemButton.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 10.4.2022.
//

import SwiftUI

struct IconCircleButton: View {
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action, label: {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
                .font(.title2)
                .padding(16)
        })
            .frame(width: 30, height: 30)
            .background(.ultraThickMaterial)
            .clipShape(Circle())
    }
}

struct DeleteItemButton_Previews: PreviewProvider {
    static var previews: some View {
        IconCircleButton(systemImage: "minus") {}
    }
}
