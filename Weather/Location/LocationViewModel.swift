//
//  LocationViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/18/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import Foundation
import os

class LocationViewModel: NSObject {
    private let queue = DispatchQueue(label: "LocationViewModel")

    private let fetchedResultsController: NSFetchedResultsController<Location>

    private let weatherAPI: YahooWeatherAPI

    @objc dynamic var results: [LocationTableViewCellViewModel]

    init(managedObjectContext: NSManagedObjectContext, weatherAPI: YahooWeatherAPI) throws {
        self.weatherAPI = weatherAPI

        let fetchRequest: NSFetchRequest = Location.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: true),
        ]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        self.fetchedResultsController = fetchedResultsController

        try fetchedResultsController.performFetch()

        let viewModels = fetchedResultsController.fetchedObjects?
            .enumerated()
            .map { LocationTableViewCellViewModel(managedObjectContext: managedObjectContext,
                                                  index: $0.offset,
                                                  location: $0.element,
                                                  weatherAPI: weatherAPI) }
        self.results = viewModels ?? []

        super.init()

        fetchedResultsController.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.managedObjectContextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }

    @objc func managedObjectContextDidSave(_ notification: Notification) {
        self.fetchedResultsController.managedObjectContext.mergeChanges(fromContextDidSave: notification)
    }

    func deleteLocation(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        self.queue.async { [weak self] in
            guard let self = self else {
                return
            }

            let managedObjectContext = self.fetchedResultsController.managedObjectContext

            managedObjectContext.delete(self.results[indexPath.row].location)

            completion(Result { try managedObjectContext.save() })
        }
    }
}

extension LocationViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects as? [Location] else {
            return
        }

        self.results = fetchedObjects.enumerated()
            .map { LocationTableViewCellViewModel(managedObjectContext: controller.managedObjectContext,
                                                  index: $0.offset,
                                                  location: $0.element,
                                                  weatherAPI: self.weatherAPI) }
    }
}
