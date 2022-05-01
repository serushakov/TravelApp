//
//  ItineraryMap.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 1.5.2022.
//

import MapKit
import SwiftUI

class StepAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    let ordinal: Int?
    let title: String?
    let type: StepType

    init(title: String, type: StepType, coordinate: CLLocationCoordinate2D, ordinal: Int?) {
        self.title = title
        self.type = type
        self.coordinate = coordinate
        self.ordinal = ordinal
    }
}

struct MapViewAdvance: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    @Binding var steps: [StepDescriptor]

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView: MKAnnotationView?

            if let annotation = annotation as? StepAnnotation {
                let view = MKMarkerAnnotationView()
                view.annotation = annotation
                switch annotation.type {
                case .step:
                    view.glyphImage = UIImage(systemName: "\(annotation.ordinal!).circle")
                case .departure:
                    view.glyphImage = UIImage(systemName: "airplane.departure")
                case .arrival:
                    view.glyphImage = UIImage(systemName: "airplane.arrival")
                case .hub:
                    view.glyphImage = UIImage(systemName: "house.fill")
                }
                annotationView = view
            }
            return annotationView
        }
    }

    var region: MKMapRect {
        let coordinates = steps.map { step in
            step.location
        }

        let rects = coordinates.lazy.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
        let rect = rects.reduce(MKMapRect.null) { $0.union($1) }

        return rect
    }

    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.delegate = context.coordinator
        view.register(StepAnnotation.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(StepAnnotation.self))

        return view
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.visibleMapRect = uiView.mapRectThatFits(region, edgePadding: UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32))

        uiView.addAnnotations(
            steps.map { step in
                StepAnnotation(title: step.title, type: step.type, coordinate: step.location,
                               ordinal: step.ordinal)
            })
    }
}

struct ItineraryMap: View {
    let steps: [StepDescriptor]

    var mapRect: MKMapRect {
        let coordinates = steps.map { step in
            step.location
        }

        let rects = coordinates.lazy.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
        let rect = rects.reduce(MKMapRect.null) { $0.union($1) }

        return rect
    }

    var body: some View {
        MapViewAdvance(steps: .constant(steps))
//        Map(mapRect: Binding.constant(mapRect), annotationItems: steps) { item in
//            MapAnnotation(coordinate: item.location) {
//                switch item.type {
//                case .step:
//                    VStack {
//                        Image(systemName: "\(item.ordinal!).circle")
//                            .resizable()
//                            .foregroundColor(.white)
//                            .frame(width: 24, height: 24)
//                            .padding(8)
//                            .background(.red)
//                            .clipShape(Circle())
//                    }
//                case .arrival:
//                    VStack {
//                        Image(systemName: "airplane.arrival")
//                            .resizable()
//                            .foregroundColor(.white)
//                            .frame(width: 24, height: 24)
//                            .padding(8)
//                            .background(.red)
//                            .clipShape(Circle())
//                    }
//                case .departure:
//                    VStack {
//                        Image(systemName: "airplane.departure")
//                            .resizable()
//                            .foregroundColor(.white)
//                            .frame(width: 24, height: 24)
//                            .padding(8)
//                            .background(.red)
//                            .clipShape(Circle())
//                    }
//                case .hub:
//                    VStack {
//                        Image(systemName: "house.fill")
//                            .resizable()
//                            .foregroundColor(.white)
//                            .frame(width: 24, height: 24)
//                            .padding(8)
//                            .background(.red)
//                            .clipShape(Circle())
//                    }
//                }
//            }
//        }
    }
}

// struct ItineraryMap_Previews: PreviewProvider {
//    static var previews: some View {
//        ItineraryMap()
//    }
// }
