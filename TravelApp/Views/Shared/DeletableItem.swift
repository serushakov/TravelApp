//
//  EditableItem.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 17.4.2022.
//

import SwiftUI

struct DeletableItem<Content: View>: View {
    var content: Content
    var isEditing: Bool
    var onDelete: () -> Void

    init(isEditing: Bool, onDelete: @escaping () -> Void, @ViewBuilder _ content: () -> Content) {
        self.isEditing = isEditing
        self.onDelete = onDelete
        self.content = content()
    }

    var body: some View {
        let scale = isEditing ? 0.9 : 1

        return ZStack(alignment: .topLeading) {
            content

            if isEditing {
                DeleteItemButton {
                    onDelete()
                }
                .offset(x: -12, y: -12)

                .transition(.asymmetric(
                    insertion: .scale(scale: 0, anchor: UnitPoint.topLeading),
                    removal: .opacity)
                )
                .zIndex(1)
            }
        }
        .animation(.easeOut, value: isEditing)
        .scaleEffect(scale)
        .animation(.spring(), value: scale)
        .transition(.scale)
    }
}

struct EditableItem_Previews: PreviewProvider {
    static var previews: some View {
        DeletableItem(isEditing: true, onDelete: {}) {
            Rectangle()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
        }
    }
}
