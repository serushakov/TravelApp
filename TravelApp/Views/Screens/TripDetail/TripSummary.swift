//
//  TripSummary.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import SwiftUI

struct TripSummary: View {
    let trip: Trip

    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .named("scroll")).minY
    }

    // 2
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)

        // Image was pulled down
        if offset > 0 {
            return -offset
        } else {
            return -offset * 0.2
        }
    }

    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }

    var body: some View {
        ScrollView {
            VStack {
                GeometryReader { proxy in
                    VStack {
                        if let imageUrl = trip.image?.url {
                            BlurHashImage(url: URL(string: imageUrl)!, blurHash: trip.image!.blurHash, size: CGSize(width: 4, height: 3))
                        } else {
                            Image("download")
                                .frame(height: 500)
                        }
                    }
                    .frame(width: proxy.size.width, height: self.getHeightForHeaderImage(proxy))
                    .clipped()

                    .offset(x: 0, y: self.getOffsetForHeaderImage(proxy))

                }.frame(height: 300)

                VStack(alignment: .leading) {
                    Text(trip.destination!.name!)
                        .font(.largeTitle.bold())
                }
                .padding()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .background(.background)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct TripSummary_Previews: PreviewProvider {
    static let moc = PersistenceController.preview.container.viewContext
    static var previews: some View {
        let trip = Trip(context: moc)
        let destination = Destination(context: moc)
        trip.destination = destination
        destination.name = "Paris"
        destination.country = "France"
        destination.latitude = 48.864716
        destination.longitude = 2.349014
        destination.radius = 28782
        trip.createdAt = Date.now

        return NavigationView {
            TripSummary(trip: trip)
                .environment(\.managedObjectContext, moc)
        }
    }
}
