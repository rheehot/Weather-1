//
//  AppDelegate.swift
//  Weather
//
//  Created by 진재명 on 8/13/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import os
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let window = UIWindow()
        self.window = window

        let appID: String! = Bundle.main.object(forInfoDictionaryKey: "YahooAppID") as? String
        assert(appID != nil)

        let clientID: String! = Bundle.main.object(forInfoDictionaryKey: "YahooClientID") as? String
        assert(clientID != nil)

        let clientSecret: String! = Bundle.main.object(forInfoDictionaryKey: "YahooClientSecret") as? String
        assert(clientSecret != nil)

        let weatherAPI = YahooWeatherAPI(appID: appID, clientID: clientID, clientSecret: clientSecret)

        window.rootViewController = MainViewController(viewModel: MainViewModel(managedObjectContext: self.persistentContainer.newBackgroundContext(), weatherAPI: weatherAPI))
        window.makeKeyAndVisible()

        return true
    }

    func applicationWillTerminate(_: UIApplication) {
        self.saveContext()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Weather")
        container.loadPersistentStores { _, error in
            guard error == nil else {
                let message = "\(error!)"
                os_log(.error, "%@", message)
                fatalError(message)
            }
        }
        return container
    }()

    func saveContext() {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let message = "\(error)"
                os_log(.error, "%@", message)
                fatalError(message)
            }
        }
    }
}
