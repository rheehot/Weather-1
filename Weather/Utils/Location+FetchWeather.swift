//
//  Location+FetchWeather.swift
//  Weather
//
//  Created by 진재명 on 8/21/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation

extension Location {
    func fetchWeather(weatherAPI: YahooWeatherAPI, force: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) -> URLSessionTask? {
        guard let managedObjectContext = self.managedObjectContext else {
            return nil
        }

        let needsUpdate = self.updatedAt == nil ? true : Date().timeIntervalSince(self.updatedAt!) > 900

        guard force || needsUpdate else {
            return nil
        }

        let latitude: CLLocationDegrees! = self.latitude?.doubleValue
        assert(latitude != nil)

        let longitude: CLLocationDegrees! = self.longitude?.doubleValue
        assert(longitude != nil)

        return weatherAPI.query(latitude: latitude, longitude: longitude) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(response):
                if let weather = self.weather {
                    managedObjectContext.delete(weather)
                }

                let weather = Weather(context: managedObjectContext, response: response)
                self.weather = weather
                weather.location = self
                
                self.updatedAt = Date()

                completion(Result { try managedObjectContext.save() })
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
