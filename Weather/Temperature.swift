//
//  Temperature.swift
//  Weather
//
//  Created by 진재명 on 8/21/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

enum Temperature: Int {
    static let userDefaultsKey = "TemperatureUserDefaultsKey"

    case celsius = 0

    case fahrenheit = 1

    var unit: UnitTemperature {
        switch self {
        case .celsius:
            return .celsius
        case .fahrenheit:
            return .fahrenheit
        }
    }
}
