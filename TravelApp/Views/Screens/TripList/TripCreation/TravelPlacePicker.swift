//
//  TravelPlacePicker.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 24.4.2022.
//

import MapKit
import SwiftUI

struct TravelPlacePicker: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var locationSearchService = LocationSearchService()
    @Environment(\.dismiss) var dismiss

    @Binding var place: PointOfInterest?

    private func createPoi(from mapItem: MKMapItem) {
        let poi = PointOfInterest(context: managedObjectContext)

        poi.name = mapItem.name
        poi.address = mapItem.placemark.title
        poi.latitude = mapItem.placemark.coordinate.latitude
        poi.longitude = mapItem.placemark.coordinate.longitude
        poi.addedAt = Date.now

        place = poi
        dismiss()
    }

    private func getTag(for mapItem: MKMapItem) -> some View {
        guard let category = mapItem.pointOfInterestCategory else { return AnyView(EmptyView()) }

        switch category {
        case .airport:
            return AnyView(Tag(color: .orange) {
                Image(systemName: "airplane.arrival")
            })
        case .publicTransport:
            return AnyView(Tag(color: .cyan) {
                Image(systemName: "bus.fill")
            })
        default:
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        SwiftUI.List {
            ForEach(locationSearchService.completions) { completion in
                Button {
                    createPoi(from: completion)
                } label: {
                    HStack {
                        Text(completion.name!)
                        Spacer()
                        getTag(for: completion)
                    }
                }.buttonStyle(.plain)
            }
        }.searchable(text: $locationSearchService.searchQuery, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct TravelPlacePicker_Previews: PreviewProvider {
    @State static var place: PointOfInterest? = nil
    static var previews: some View {
        TravelPlacePicker(place: $place)
    }
}
