//
//  SearchViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import Foundation
import MapKit
import os

class SearchViewModel {
    private let queue = DispatchQueue(label: "SearchViewModel")

    private let locationSearchManager = SearchManager()

    private let managedObjectContext: NSManagedObjectContext

    var results: [SearchItemTableViewCellViewModel] = []

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func search(query: String, completion: @escaping (Result<[SearchItemTableViewCellViewModel], Error>) -> Void) {
        self.locationSearchManager.search(query: query) { [weak self] results in
            guard let self = self else {
                return
            }

            switch results {
            case let .success(locations):
                let results = self.results
                self.results = locations.enumerated().map(SearchItemTableViewCellViewModel.init)
                completion(.success(results))
            case let .failure(error as NSError):
                switch (error.domain, error.code) {
                case (MKError.errorDomain, Int(MKError.Code.placemarkNotFound.rawValue)):
                    let results = self.results
                    self.results = []
                    completion(.success(results))
                default:
                    completion(.failure(error))
                }
            }
        }
    }

    func didSelect(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        self.queue.async {
            let viewModel = self.results[indexPath.row]

            let location = Location(context: self.managedObjectContext)
            location.title = viewModel.location.title
            location.subtitle = viewModel.location.subtitle
            location.latitude = viewModel.location.latitude as NSNumber
            location.longitude = viewModel.location.longitude as NSNumber
            location.createdAt = Date()

            completion(Result { try self.managedObjectContext.save() })
        }
    }
}
