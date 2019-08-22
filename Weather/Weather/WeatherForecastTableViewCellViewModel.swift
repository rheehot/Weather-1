//
//  WeatherForecastTableViewCellViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

class WeatherForecastTableViewCellViewModel: TableViewCellViewModel {
    static let reuseIdentifier = "WeatherForecastTableViewCellViewModelReuseIdentifier"

    let forecast: Forecast

    init(forecast: Forecast) {
        self.forecast = forecast
    }
}
