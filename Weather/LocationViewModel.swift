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
    static let errorOccurredNotification = Notification.Name(rawValue: "LocationViewModel.errorOccurredNotification")

    static let errorUserInfoKey = "LocationViewModel.errorUserInfoKey"

    private let fetchedResultsController: NSFetchedResultsController<Location>

    @objc dynamic var results: [LocationTableViewCellViewModel] = []

    init(managedObjectContext: NSManagedObjectContext) {
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

        do {
            try fetchedResultsController.performFetch()

            if let fetchedObjects = fetchedResultsController.fetchedObjects?.enumerated().map(LocationTableViewCellViewModel.init) {
                self.results = fetchedObjects
            }
        } catch {
            NotificationCenter.default.post(name: LocationViewModel.errorOccurredNotification,
                                            object: self,
                                            userInfo: [LocationViewModel.errorUserInfoKey: error])
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.managedObjectContextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }

    @objc func managedObjectContextDidSave(_ notification: Notification) {
        self.fetchedResultsController.managedObjectContext.mergeChanges(fromContextDidSave: notification)
    }
}

extension LocationViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects as? [Location] else {
            return
        }
        self.results = fetchedObjects.enumerated().map(LocationTableViewCellViewModel.init)
    }
}
