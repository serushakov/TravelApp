//
//  SectionListHeader.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 17.4.2022.
//

import SwiftUI

struct ListSectionHeader: View {
    @Environment(\.editMode) private var editMode

    var title: String
    var onAdd: () -> Void
    var onDelete: () -> Void

    private var isEditing: Bool {
        editMode?.wrappedValue == EditMode.active
    }

    private var deletable: Bool

    init(
        title: String,
        onAdd: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.title = title
        self.onAdd = onAdd
        self.onDelete = onDelete
        self.deletable = true
    }

    init(
        title: String,
        onAdd: @escaping () -> Void
    ) {
        self.title = title
        self.onAdd = onAdd
        self.onDelete = {}
        self.deletable = false
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
            Spacer()
            Button {
                if isEditing && deletable {
                    onDelete()
                } else {
                    onAdd()
                }
            } label: {
                if isEditing && deletable {
                    Text("Delete")
                        .foregroundColor(.red)
                } else {
                    Label("Add item to list", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                }
            }
            .animation(.easeOut, value: editMode?.wrappedValue)
            .transition(.opacity)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct SectionListHeader_Previews: PreviewProvider {
    static var previews: some View {
        ListSectionHeader(title: "List section", onAdd: {}, onDelete: {})
            .previewLayout(.sizeThatFits)
    }
}
