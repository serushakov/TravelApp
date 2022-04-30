//
//  AddStepButton.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 30.4.2022.
//

import SwiftUI

struct AddStepButton: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "plus.circle")
                .font(.largeTitle)
                .padding(.vertical, -2)

            Text("Add step")
                .font(.body.bold())
        }.foregroundColor(.blue)
    }
}

struct AddStepButton_Previews: PreviewProvider {
    static var previews: some View {
        AddStepButton()
            .previewLayout(.sizeThatFits)
    }
}
