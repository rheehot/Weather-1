//
//  SearchManager.swift
//  Weather
//
//  Created by 진재명 on 8/18/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation
import MapKit

class SearchManager {
    struct Location: Hashable {
        let title: String

        let subtitle: String

        let latitude: CLLocationDegrees

        let longitude: CLLocationDegrees

        init?(placemark: MKPlacemark) {
            guard let title = placemark.name else {
                return nil
            }

            self.title = title

            self.subtitle = [
                placemark.postalCode,
                placemark.country,
                placemark.administrativeArea,
                placemark.subAdministrativeArea,
                placemark.locality,
                placemark.subLocality,
                placemark.thoroughfare,
                placemark.subThoroughfare,
            ]
            .compactMap { $0 }
            .joined(separator: ", ")

            guard let location = placemark.location else {
                return nil
            }

            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }

    private var localSearch: MKLocalSearch?

    func search(query: String, completion: @escaping (Result<[Location], Error>) -> Void) {
        self.localSearch?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let localSearch = MKLocalSearch(request: request)
        self.localSearch = localSearch
        localSearch.start { [weak self] response, error in
            guard let self = self else {
                return
            }

            defer {
                self.localSearch = nil
            }

            guard error == nil else {
                completion(.failure(error!))
                return
            }

            guard let response = response else {
                completion(.failure(MKError(.unknown)))
                return
            }

            let results = response.mapItems.compactMap { Location(placemark: $0.placemark) }
            completion(.success(results))
        }
    }
}
