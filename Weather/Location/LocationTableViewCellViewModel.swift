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
    static let errorOccurredNotification = Notification.Name(rawValue: "LocationTableViewCellViewModel.errorOccurredNotification")

    static let errorUserInfoKey = "LocationTableViewCellViewModel.errorUserInfoKey"

    static let reuseIdentifier = "LocationTableViewCellViewModel.reuseIdentifier"

    let indexPath: IndexPath

    let location: Location

    let weatherAPI: YahooWeatherAPI

    let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext, indexPath: IndexPath, location: Location, weatherAPI: YahooWeatherAPI) {
        self.managedObjectContext = managedObjectContext
        self.indexPath = indexPath
        self.location = location
        self.weatherAPI = weatherAPI

        super.init()

        self.fetchWeather { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                break
            case let .failure(error):
                NotificationCenter.default.post(name: LocationTableViewCellViewModel.errorOccurredNotification,
                                                object: self,
                                                userInfo: [LocationTableViewCellViewModel.errorUserInfoKey: error])
            }
        }
    }

    convenience init(managedObjectContext: NSManagedObjectContext, index: Int, location: Location, weatherAPI: YahooWeatherAPI) {
        self.init(managedObjectContext: managedObjectContext,
                  indexPath: IndexPath(row: index, section: 0),
                  location: location,
                  weatherAPI: weatherAPI)
    }

    override var hash: Int {
        return self.indexPath.hashValue ^ self.location.hashValue
    }

    var sessionTask: URLSessionTask?

    func fetchWeather(completion: @escaping (Result<Void, Error>) -> Void) {
        guard self.location.needsUpdateWeather else {
            return
        }

        self.sessionTask?.cancel()

        let latitude: CLLocationDegrees! = self.location.latitude?.doubleValue
        assert(latitude != nil)

        let longitude: CLLocationDegrees! = self.location.longitude?.doubleValue
        assert(longitude != nil)

        self.sessionTask = self.weatherAPI.query(latitude: latitude, longitude: longitude) { [weak self] result in
            guard let self = self else {
                return
            }

            defer {
                self.sessionTask = nil
            }

            switch result {
            case let .success(response):
                if let weather = self.location.weather {
                    self.managedObjectContext.delete(weather)
                }

                self.location.weather = Weather(context: self.managedObjectContext, response: response)
                self.location.updatedAt = Date()

                completion(Result { try self.managedObjectContext.save() })
            case let .failure(error):
                NotificationCenter.default.post(name: LocationTableViewCellViewModel.errorOccurredNotification,
                                                object: self,
                                                userInfo: [LocationTableViewCellViewModel.errorUserInfoKey: error])
            }
        }
    }
}

extension Location {
    var needsUpdateWeather: Bool {
        guard let updatedAt = self.updatedAt else {
            return true
        }
        return Date().timeIntervalSince(updatedAt) > 900
    }
}

extension Weather {
    convenience init(context: NSManagedObjectContext, response: YahooWeatherAPI.Response) {
        self.init(context: context)

        self.woeid = response.location.woeid as NSNumber
        self.city = response.location.city
        self.region = response.location.region
        self.country = response.location.country
        self.latitude = response.location.latitude as NSNumber
        self.longitude = response.location.longitude as NSNumber
        self.timeZone = response.location.timeZone

        self.chill = response.currentObservation.wind.chill as NSNumber
        self.direction = response.currentObservation.wind.direction as NSNumber
        self.speed = response.currentObservation.wind.speed as NSNumber

        self.humidity = response.currentObservation.atmosphere.humidity as NSNumber
        self.visibility = response.currentObservation.atmosphere.visibility as NSNumber
        self.pressure = response.currentObservation.atmosphere.pressure as NSNumber
        self.rising = response.currentObservation.atmosphere.rising.rawValue as NSNumber

        self.sunrise = response.currentObservation.astronomy.sunrise
        self.sunset = response.currentObservation.astronomy.sunset

        self.text = response.currentObservation.condition.text
        self.code = response.currentObservation.condition.code.rawValue as NSNumber

        let converter = UnitTemperature.celsius.converter
        self.temperature = converter.baseUnitValue(fromValue: Double(response.currentObservation.condition.temperature)) as NSNumber

        self.publicationDate = response.currentObservation.publicationDate

        self.forecasts = []
    }
}
