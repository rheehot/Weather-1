//
//  YahooWeatherAPI+Response+Forecast.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension YahooWeatherAPI.Response {
    struct Forecast: Decodable {
        enum Weekday: String, Decodable {
            case sunday = "Sun"
            case monday = "Mon"
            case tuesday = "Tue"
            case wednesday = "Wed"
            case thursday = "Thu"
            case friday = "Fri"
            case saturday = "Sat"
        }

        let weekday: Weekday

        let date: Date

        let lowTemperature: Int

        let highTemperature: Int

        let text: String

        let code: Code

        enum CodingKeys: String, CodingKey {
            case weekday = "day"
            case date
            case lowTemperature = "low"
            case highTemperature = "high"
            case text
            case code
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.weekday = try values.decode(Weekday.self, forKey: .weekday)

            let timeInterval = try TimeInterval(values.decode(Int.self, forKey: .date))
            self.date = Date(timeIntervalSince1970: timeInterval)

            self.lowTemperature = try values.decode(Int.self, forKey: .lowTemperature)
            self.highTemperature = try values.decode(Int.self, forKey: .highTemperature)
            self.text = try values.decode(String.self, forKey: .text)
            self.code = try values.decode(Code.self, forKey: .code)
        }
    }
}
