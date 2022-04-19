//
//  EditableItem.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 17.4.2022.
//

import SwiftUI

struct DeletableItem<Content: View>: View {
    @Environment(\.editMode) private var editMode

    var content: Content
    var onDelete: () -> Void

    init(onDelete: @escaping () -> Void, @ViewBuilder _ content: () -> Content) {
        self.onDelete = onDelete
        self.content = content()
    }

    var body: some View {
        let scale = editMode?.wrappedValue == EditMode.active ? 0.9 : 1

        return ZStack(alignment: .topLeading) {
            content

            if editMode?.wrappedValue == EditMode.active {
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
        .animation(.easeOut, value: editMode?.wrappedValue)
        .scaleEffect(scale)
        .animation(.spring(), value: scale)
        .transition(.scale)
        .onChange(of: editMode?.wrappedValue) { value in
            print(value)
        }
    }
}

struct EditableItem_Previews: PreviewProvider {
    static var previews: some View {
        DeletableItem(onDelete: {}) {
            Rectangle()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
        }
    }
}
