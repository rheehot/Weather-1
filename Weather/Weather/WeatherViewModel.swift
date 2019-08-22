//
//  WeatherViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

class WeatherViewModel: NSObject {
    static let errorOccurredNotification = Notification.Name(rawValue: "WeatherViewModelErrorOccurredNotification")

    static let errorUserInfoKey = "WeatherViewModelErrorUserInfoKey"

    let index: Int

    let location: Location

    var timer: Timer?

    var sessionTask: URLSessionTask?

    var results: [TableViewCellViewModel] = []

    init(index: Int, location: Location, weatherAPI: YahooWeatherAPI) {
        self.index = index
        self.location = location

        super.init()

        if let weather = location.weather {
            var results: [TableViewCellViewModel] = []

            results.append(WeatherLocationTableViewCellViewModel(weather: weather))
            results.append(WeatherConditionTableViewCellViewModel(weather: weather))
            results.append(WeatherAstronomyTableViewCellViewModel(weather: weather))
            results.append(WeatherAtmosphereTableViewCellViewModel(weather: weather))
            results.append(WeatherWindTableViewCellViewModel(weather: weather))
            results.append(contentsOf: weather.forecasts?.map { forecast in
                assert(forecast is Forecast)
                return WeatherForecastTableViewCellViewModel(forecast: forecast as! Forecast)
            } ?? [])

            self.results = results
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.sessionTask?.cancel()
            self.sessionTask = location.fetchWeather(weatherAPI: weatherAPI) { result in
                if case let .failure(error) = result {
                    NotificationCenter.default.post(name: WeatherViewModel.errorOccurredNotification,
                                                    object: self,
                                                    userInfo: [WeatherViewModel.errorUserInfoKey: error])
                }
            }
        }
        self.timer = timer
        timer.fire()
    }
}
