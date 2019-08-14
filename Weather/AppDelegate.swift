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

        let rootViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        rootViewController.setViewControllers([MainViewController()], direction: .forward, animated: false)
        rootViewController.dataSource = self
        rootViewController.delegate = self

        window.rootViewController = rootViewController
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
                let message = String(describing: error!)
                os_log(.error, "%@", message as NSString)
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
                let message = String(describing: error)
                os_log(.error, "%@", message as NSString)
                fatalError(message)
            }
        }
    }
}

extension AppDelegate: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore _: UIViewController) -> UIViewController? {
        return MainViewController()
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter _: UIViewController) -> UIViewController? {
        return MainViewController()
    }
}

extension AppDelegate: UIPageViewControllerDelegate {}
