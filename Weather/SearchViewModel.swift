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
    private let locationSearchManager = LocationSearchManager()

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
            case let .success(results):
                let results = results.enumerated().map(SearchItemTableViewCellViewModel.init)
                completion(.success(results))
                self.results = results
            case let .failure(error as NSError):
                switch (error.domain, error.code) {
                case (MKError.errorDomain, Int(MKError.Code.placemarkNotFound.rawValue)):
                    let results: [SearchItemTableViewCellViewModel] = []
                    completion(.success(results))
                    self.results = results
                default:
                    completion(.failure(error))
                }
            }
        }
    }

    func didSelect(at indexPath: IndexPath, completion: (Result<Void, Error>) -> Void) {
        let viewModel = self.results[indexPath.row]

        let location = Location(context: self.managedObjectContext)
        location.title = viewModel.location.title
        location.subtitle = viewModel.location.subtitle
        location.latitude = viewModel.location.latitude as NSNumber
        location.longitude = viewModel.location.longitude as NSNumber
        location.createdAt = Date()

        if self.managedObjectContext.hasChanges {
            completion(Result {
                try self.managedObjectContext.save()
            })
        }
    }
}
