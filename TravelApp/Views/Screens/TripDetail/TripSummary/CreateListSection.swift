//
//  CreateListSection.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 16.4.2022.
//

import SwiftUI

struct CreateListSection: View {
    let onSectionCreated: (String) -> Void

    @State var isCreating = false
    @State var name = ""
    @FocusState var isNameFieldFocused: Bool

    var body: some View {
        VStack {
            if !isCreating {
                Button {
                    isCreating = true
                } label: {
                    Label("Add section", systemImage: "plus.circle")
                        .font(.title3.bold())
                }
            } else {
                TextField("Name", text: $name)
                    .focused($isNameFieldFocused, equals: true)
                    .textFieldStyle(.plain)
                    .onAppear {
                        isNameFieldFocused = true
                    }
                    .font(.title2.bold())
                    .submitLabel(.done)
                    .onSubmit {
                        if !name.isEmpty {
                            onSectionCreated(name)
                        }
                        isCreating = false
                        isNameFieldFocused = false
                        name = ""
                    }
            }
        }
    }
}

struct CreateListSection_Previews: PreviewProvider {
    static var previews: some View {
        CreateListSection { _ in }
            .previewLayout(.sizeThatFits)
    }
}
