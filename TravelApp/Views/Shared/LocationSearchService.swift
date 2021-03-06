//
//  LocationSearchService.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 6.4.2022.
//

import Combine
import Foundation
import MapKit
import SwiftUI

/**
 Service that serves as an interface to MKLocalSearchCompleter and MKLocalSearch.
 For a given `searchQuery` if will fetch up to 5 completion results via MKLocalSearchCompleter and
 then fetch MKMapItem for all of those results. As an output it provides a @Published `completions`.

 `state` allows for communicating state of the search to the user
 */
class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    @Published var completions: [MKMapItem] = []
    @Published var state: State = .idle

    let poiFilter: MKPointOfInterestFilter?

    var completer: MKLocalSearchCompleter
    var cancellable: AnyCancellable?

    enum State {
        case loading, idle
    }

    init(
        poiFilter: MKPointOfInterestFilter? = nil,
        region: MKCoordinateRegion? = nil
    ) {
        self.completer = MKLocalSearchCompleter()
        self.poiFilter = poiFilter
        self.completer.region = region ?? MKCoordinateRegion(.world)

        super.init()

        self.cancellable = $searchQuery
            .map { value in
                if self.state == .loading {
                    // Cancel any in-flight query
                    self.completer.cancel()
                } else {
                    self.state = .loading
                }

                if value.isEmpty {
                    self.completions = []
                    self.state = .idle
                }

                return value
            }
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { value in

                self.completer.queryFragment = value
            }

        self.completer.delegate = self
    }

    deinit {
        self.cancellable?.cancel()
        self.completer.cancel()
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Take top 5 results
        let completions = completer.results
            .prefix(5)

        Task {
            let mapItems = await self.processCompletions(completions: Array(completions))

            DispatchQueue.main.async {
                self.completions = mapItems
                self.state = .idle
            }
        }
    }

    func processCompletions(completions: [MKLocalSearchCompletion]) async -> [MKMapItem] {
        do {
            return try await completions
                .asyncMap(self.fetchMapItemForCompletion)
                .compactMap { $0 } // Filter out all nil
        } catch {
            return []
        }
    }

    /**
     Returns a MKMapItem for a given MKLocalSearchCompletion.
     */
    func fetchMapItemForCompletion(completion: MKLocalSearchCompletion) async throws -> MKMapItem? {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        searchRequest.region = MKCoordinateRegion(.world)

        let search = MKLocalSearch(request: searchRequest)
        let result = try await search.start()

        return result.mapItems.first
    }
}

extension MKLocalSearchCompletion: Identifiable {}
extension MKMapItem: Identifiable {}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
