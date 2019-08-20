//
//  YahooWeatherAPI+Response+CurrentObservation+Condition.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension YahooWeatherAPI.Response.CurrentObservation {
    struct Condition: Decodable {
        let text: String

        let code: YahooWeatherAPI.Response.Code

        let temperature: Int
    }
}
