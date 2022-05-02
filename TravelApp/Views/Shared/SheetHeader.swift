//
//  SheetHeader.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI

/**
 A nice header for a bottom sheet
 Includes a close button
 */
struct SheetHeader: View {
    var title: String
    var closeButtonAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 40, height: 6)
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.top, 8)

            HStack(alignment: .center) {
                Text(title)
                    .font(.title.bold())
                Spacer()
                Button(action: closeButtonAction) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct SheetHeader_Previews: PreviewProvider {
    @State static var isOpened = true

    static var previews: some View {
        VStack {}.sheet(isPresented: $isOpened) {
            SheetHeader(title: "Sheet header") {}
            Spacer()
        }
    }
}
