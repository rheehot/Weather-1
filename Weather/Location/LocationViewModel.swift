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
    let fetchedResultsController: NSFetchedResultsController<Location>

    @objc dynamic var results: [LocationTableViewCellViewModel] = []

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

    func performFetch() throws {
        try self.fetchedResultsController.performFetch()
        let fetchedObjects: [Location]! = self.fetchedResultsController.fetchedObjects
        assert(fetchedObjects != nil)
        self.results = fetchedObjects.enumerated().map { LocationTableViewCellViewModel(index: $0.offset, location: $0.element, weatherAPI: self.weatherAPI) }
    }

    @objc func managedObjectContextDidSave(_ notification: Notification) {
        self.fetchedResultsController.managedObjectContext.mergeChanges(fromContextDidSave: notification)
    }

    var changeIsUserDriven = false

    func deleteLocation(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        let managedObjectContext = self.fetchedResultsController.managedObjectContext
        managedObjectContext.delete(self.results[indexPath.row].location)
        self.results.remove(at: indexPath.row)
        completion(Result { try managedObjectContext.save() })
    }

    func updateLocation(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        self.results[indexPath.row].updateLocation { result in
            completion(result)
        }
    }
}

extension LocationViewModel: NSFetchedResultsControllerDelegate {
    static let willChangeContentNotification = Notification.Name(rawValue: "LocationViewModelWillChangeContentNotification")

    static let didChangeContentNotification = Notification.Name(rawValue: "LocationViewModelDidChangeContentNotification")

    static let didInsertObjectNotification = Notification.Name(rawValue: "LocationViewModelDidInsertObjectNotification")

    static let didMoveObjectNotification = Notification.Name(rawValue: "LocationViewModelDidMoveObjectNotification")

    static let didDeleteObjectNotification = Notification.Name(rawValue: "LocationViewModelDidDeleteObjectNotification")

    static let didUpdateObjectNotification = Notification.Name(rawValue: "LocationViewModelDidUpdateObjectNotification")

    static let controllerUserInfoKey = "LocationViewModelControllerUserInfoKey"

    static let objectUserInfoKey = "LocationViewModelObjectUserInfoKey"

    static let indexPathUserInfoKey = "LocationViewModelIndexPathUserInfoKey"

    static let newIndexPathUserInfoKey = "LocationViewModelNewIndexPathUserInfoKey"

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(name: LocationViewModel.willChangeContentNotification,
                                        object: self,
                                        userInfo: [LocationViewModel.controllerUserInfoKey: controller])
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard !self.changeIsUserDriven else {
            return
        }

        let object: Location! = anObject as? Location
        assert(object != nil)

        switch type {
        case .insert:
            let newIndexPath: IndexPath! = newIndexPath
            assert(newIndexPath != nil)

            self.results.insert(LocationTableViewCellViewModel(index: newIndexPath.row, location: object, weatherAPI: self.weatherAPI), at: newIndexPath.row)
            NotificationCenter.default.post(name: LocationViewModel.didInsertObjectNotification,
                                            object: self,
                                            userInfo: [
                                                LocationViewModel.controllerUserInfoKey: controller,
                                                LocationViewModel.objectUserInfoKey: object!,
                                                LocationViewModel.newIndexPathUserInfoKey: newIndexPath!,
                                            ])
        case .delete:
            let indexPath: IndexPath! = indexPath
            assert(indexPath != nil)

            self.results.remove(at: indexPath.row)

            NotificationCenter.default.post(name: LocationViewModel.didDeleteObjectNotification,
                                            object: self,
                                            userInfo: [
                                                LocationViewModel.controllerUserInfoKey: controller,
                                                LocationViewModel.objectUserInfoKey: object!,
                                                LocationViewModel.indexPathUserInfoKey: indexPath!,
                                            ])
        case .move:
            let indexPath: IndexPath! = indexPath
            assert(indexPath != nil)

            let newIndexPath: IndexPath! = newIndexPath
            assert(newIndexPath != nil)

            self.results.remove(at: indexPath.row)
            self.results.insert(LocationTableViewCellViewModel(index: newIndexPath.row, location: object, weatherAPI: self.weatherAPI), at: newIndexPath.row)

            NotificationCenter.default.post(name: LocationViewModel.didMoveObjectNotification,
                                            object: self,
                                            userInfo: [
                                                LocationViewModel.controllerUserInfoKey: controller,
                                                LocationViewModel.objectUserInfoKey: object!,
                                                LocationViewModel.indexPathUserInfoKey: indexPath!,
                                                LocationViewModel.newIndexPathUserInfoKey: newIndexPath!,
                                            ])
        case .update:
            let indexPath: IndexPath! = indexPath
            assert(indexPath != nil)

            let newIndexPath: IndexPath! = newIndexPath
            assert(newIndexPath != nil)

            self.results[indexPath.row] = LocationTableViewCellViewModel(index: newIndexPath.row, location: object, weatherAPI: self.weatherAPI)

            NotificationCenter.default.post(name: LocationViewModel.didUpdateObjectNotification,
                                            object: self,
                                            userInfo: [
                                                LocationViewModel.controllerUserInfoKey: controller,
                                                LocationViewModel.objectUserInfoKey: object!,
                                                LocationViewModel.indexPathUserInfoKey: indexPath!,
                                                LocationViewModel.newIndexPathUserInfoKey: newIndexPath!,
                                            ])
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(name: LocationViewModel.didChangeContentNotification,
                                        object: self,
                                        userInfo: [LocationViewModel.controllerUserInfoKey: controller])
    }
}
