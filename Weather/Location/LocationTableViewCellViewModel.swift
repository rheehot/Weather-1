//
//  LocationTableViewCellViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/18/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation
import os

class LocationTableViewCellViewModel: NSObject {
    static let errorOccurredNotification = Notification.Name(rawValue: "LocationTableViewCellViewModelErrorOccurredNotification")

    static let errorUserInfoKey = "LocationTableViewCellViewModelErrorUserInfoKey"

    static let reuseIdentifier = "LocationTableViewCellViewModelReuseIdentifier"

    let indexPath: IndexPath

    let location: Location

    var timer: Timer?

    deinit {
        self.timer?.invalidate()
        self.sessionTask?.cancel()
    }

    let weatherAPI: YahooWeatherAPI

    init(indexPath: IndexPath, location: Location, weatherAPI: YahooWeatherAPI) {
        self.indexPath = indexPath
        self.location = location
        self.weatherAPI = weatherAPI

        super.init()

        let timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.sessionTask?.cancel()
            self.sessionTask = location.fetchWeather(weatherAPI: weatherAPI) { result in
                if case let .failure(error) = result {
                    NotificationCenter.default.post(name: LocationTableViewCellViewModel.errorOccurredNotification,
                                                    object: self,
                                                    userInfo: [LocationTableViewCellViewModel.errorUserInfoKey: error])
                }
            }
        }
        self.timer = timer
        timer.fire()
    }

    convenience init(index: Int, location: Location, weatherAPI: YahooWeatherAPI) {
        self.init(indexPath: IndexPath(row: index, section: 0),
                  location: location,
                  weatherAPI: weatherAPI)
    }

    override var hash: Int {
        return self.indexPath.hashValue ^ self.location.hashValue
    }

    var sessionTask: URLSessionTask?

    func updateLocation(completion: @escaping (Result<Void, Error>) -> Void) {
        self.sessionTask?.cancel()
        self.sessionTask = self.location.fetchWeather(weatherAPI: self.weatherAPI, force: true) { result in
            completion(result)
        }
    }
}
