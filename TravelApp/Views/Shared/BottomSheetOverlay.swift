//
//  BottomSheetOverlay.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.3.2022.
//

import SwiftUI

struct BottomSheetOverlay<Content: View>: View {
    var isOpen: Binding<Bool>
    var maxHeight: CGFloat
    var content: Content
    @State var openPercentage: CGFloat = 0

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.maxHeight = maxHeight
        self.content = content()
        self.isOpen = isOpen
    }

    var body: some View {
        ZStack {
            Button(action: { isOpen.wrappedValue.toggle() }) {
                Color.black
                    .opacity(0.6 * openPercentage)
            }
            BottomSheet(
                isOpen: isOpen,
                maxHeight: maxHeight,
                openPercentage: $openPercentage
            ) {
                content
            }
        }
        .ignoresSafeArea(edges: .all)
        .onChange(of: $openPercentage.wrappedValue) { value in
            print(value)
        }
    }
}

struct BottomSheetOverlay_Previews: PreviewProvider {
    @State static var isOpen = true

    static var previews: some View {
        BottomSheetOverlay(isOpen: $isOpen, maxHeight: 200) {
            Text("Hello")
        }
    }
}
