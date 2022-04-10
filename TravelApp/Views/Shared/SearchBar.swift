//
//  SearchBar.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 6.4.2022.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    private var placeholder = ""

    init(text: Binding<String>) {
        _text = text
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = placeholder

        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
        uiView.placeholder = placeholder
    }

    func placeholder(_ text: String) -> SearchBar {
        var view = self
        view.placeholder = text
        return view
    }
}

struct SearchBar_Preview: PreviewProvider {
    @State static var text = "Paris"

    static var previews: some View {
        SearchBar(text: $text)
            .previewLayout(.sizeThatFits)
    }
}
