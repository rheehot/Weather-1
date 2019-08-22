//
//  MainViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/21/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import Foundation

class MainViewModel: NSObject {
    let fetchedResultsController: NSFetchedResultsController<Location>

    @objc dynamic var results: [WeatherViewModel] = []

    @objc dynamic var currentPage = 0

    let weatherAPI: YahooWeatherAPI

    init(managedObjectContext: NSManagedObjectContext, weatherAPI: YahooWeatherAPI) {
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

    func performFetch() throws {
        try self.fetchedResultsController.performFetch()

        let fetchedObjects: [Location]! = self.fetchedResultsController.fetchedObjects
        assert(fetchedObjects != nil)
        self.results = fetchedObjects.enumerated().map { WeatherViewModel(index: $0.offset, location: $0.element, weatherAPI: self.weatherAPI) }
    }
}

extension MainViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let fetchedObjects: [Location]! = controller.fetchedObjects as? [Location]
        assert(fetchedObjects != nil)
        self.results = fetchedObjects.enumerated().map { WeatherViewModel(index: $0.offset, location: $0.element, weatherAPI: self.weatherAPI) }
    }
}
