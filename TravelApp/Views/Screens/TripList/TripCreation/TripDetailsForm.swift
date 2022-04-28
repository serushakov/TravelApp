//
//  TripDetailsForm.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 24.4.2022.
//

import MapKit
import SwiftUI

struct TripDetailsForm: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    let to: MKMapItem
    var onFinished: () -> Void

    @State var arrival = Date.now
    @State var departure = Date.now
    @State var arrivalPlace: PointOfInterest? = nil
    @State var departurePlace: PointOfInterest? = nil
    @State var image: ImageWithBlurHash? = nil

    func createTrip() async {
        guard let region = to.placemark.region as? CLCircularRegion else {
            return
        }

        let destination = Destination(context: managedObjectContext)
        destination.name = to.name
        destination.country = to.placemark.country
        destination.latitude = region.center.longitude
        destination.longitude = region.center.latitude
        destination.radius = region.radius
        destination.arrival = arrivalPlace
        destination.departure = departurePlace

        let trip = Trip(context: managedObjectContext)
        trip.destination = destination
        trip.createdAt = Date.now
        trip.arrival = arrival
        trip.departure = departure
        trip.image = image

        do {
            try managedObjectContext.save()
            onFinished()
        } catch {}
    }

    private func getImage(retry: Bool = false) {
        if image == nil || retry {
            Task {
                do {
                    let image = try await ThumbnailSearchService.fetchRandomPhoto(query: to.name!)

                    if let image = image {
                        let imageWithBlurhash = ImageWithBlurHash(context: managedObjectContext)

                        imageWithBlurhash.url = image.urls.regular
                        imageWithBlurhash.thumbnail = image.urls.small_s3
                        imageWithBlurhash.blurHash = image.blur_hash
                        self.image = imageWithBlurhash
                    }
                } catch {
                    print("error", error)
                }
            }
        }
    }

    var body: some View {
        Form {
            Section {
                ZStack(alignment: .bottomLeading) {
                    if let image = image {
                        BlurHashImage(url: URL(string: image.url!)!, blurHash: image.blurHash, size: CGSize(width: 4, height: 3))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    }
                    Rectangle()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundColor(.black.opacity(0.24))
                    Text(to.name!)
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding()
                }
                .onTapGesture {
                    getImage(retry: true)
                }
            }
            .listRowInsets(EdgeInsets())
            .frame(height: 200)
            .onAppear {
                getImage()
            }
            Section {
                DatePicker("When", selection: $arrival)
                NavigationLink {
                    TravelPlacePicker(place: $arrivalPlace)
                } label: {
                    HStack {
                        Text("To")
                        Spacer(minLength: 16)
                        Text(arrivalPlace?.name ?? "")
                    }
                }
            } header: {
                Label("Arrival", systemImage: "airplane.arrival")
            }
            .onChange(of: arrivalPlace) { value in
                if departurePlace == nil {
                    departurePlace = value
                }
            }

            Section {
                DatePicker("When", selection: $departure, in: arrival ... Date.distantFuture)

                NavigationLink {
                    TravelPlacePicker(place: $departurePlace)
                } label: {
                    HStack {
                        Text("From")
                        Spacer(minLength: 16)
                        Text(departurePlace?.name ?? "")
                    }
                }
            } header: {
                Label("Departure", systemImage: "airplane.departure")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel", action: onFinished)
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Create") {
                    Task {
                        await createTrip()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .listStyle(.grouped)
    }
}

struct TripDetailsForm_Previews: PreviewProvider {
    static var previews: some View {
        let item = MKMapItem()
        item.name = "Paris"

        return TripDetailsForm(to: item) {}
    }
}
