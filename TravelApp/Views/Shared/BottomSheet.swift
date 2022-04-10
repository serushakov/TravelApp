//
//  BottomSheet.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 28.3.2022.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    @Binding var isOpen: Bool

    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    @Binding var openPercentage: CGFloat
    @GestureState private var translation: CGFloat = 0

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
        self._openPercentage = Binding.constant(0)
    }

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, openPercentage: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight
        self.maxHeight = maxHeight
        self.content = content()
        self._openPercentage = openPercentage
        self._isOpen = isOpen
    }

    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(.tertiary)
            .frame(
                width: 50,
                height: 6
            )
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                indicator.padding()
                content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: -2)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring(), value: isOpen)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                    print(minHeight / value.translation.height)
                }.onEnded { value in
                    let snapDistance = self.maxHeight * 1
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            ).onChange(of: $translation.wrappedValue) { value in
                openPercentage = (minHeight - value) / minHeight
            }
        }.ignoresSafeArea(edges: .bottom)
    }
}

struct BottomSheet_Previews: PreviewProvider {
    @State static var isOpen = true

    static var previews: some View {
        BottomSheet(isOpen: $isOpen, maxHeight: 200) {
            Text("Hello")
        }
    }
}
