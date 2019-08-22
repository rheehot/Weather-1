//
//  WeatherAstronomyTableViewCellViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

class WeatherAstronomyTableViewCellViewModel: TableViewCellViewModel {
    static let reuseIdentifier = "WeatherAstronomyTableViewCellViewModelReuseIdentifier"

    let weather: Weather

    init(weather: Weather) {
        self.weather = weather
    }
}
