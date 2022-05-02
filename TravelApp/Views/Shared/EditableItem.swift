//
//  EditableItem.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 17.4.2022.
//

import SwiftUI

enum ActionType {
    case edit
    case delete
}

/**
 Utility view that wraps any other view.
 Listens to `editMode` environment and shows a delete/edit button
 if `editMode` is `.active`.
 */
struct EditableItem<Content: View>: View {
    @Environment(\.editMode) private var editMode

    var content: Content
    var type: ActionType
    var onDelete: () -> Void

    init(onDelete: @escaping () -> Void, @ViewBuilder _ content: () -> Content) {
        self.onDelete = onDelete
        self.content = content()
        self.type = .delete
    }

    init(type: ActionType, @ViewBuilder _ content: () -> Content, onEdit: @escaping () -> Void) {
        self.onDelete = onEdit
        self.content = content()
        self.type = type
    }

    var systemImage: String {
        switch type {
        case .delete:
            return "minus"
        case .edit:
            return "pencil"
        }
    }

    var body: some View {
        let scale = editMode?.wrappedValue == EditMode.active ? 0.9 : 1

        return ZStack(alignment: .topLeading) {
            content

            if editMode?.wrappedValue == EditMode.active {
                IconCircleButton(systemImage: systemImage) {
                    onDelete()
                }
                .offset(x: -12, y: -12)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0, anchor: UnitPoint.topLeading),
                    removal: .opacity)
                )
                .zIndex(2)
            }
        }
        .animation(.easeOut, value: editMode?.wrappedValue)
        .scaleEffect(scale)
        .animation(.spring(), value: scale)
        .transition(.scale)
    }
}

struct EditableItem_Previews: PreviewProvider {
    static var previews: some View {
        EditableItem(onDelete: {}) {
            Rectangle()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
        }
    }
}
