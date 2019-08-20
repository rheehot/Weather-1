//
//  YahooWeatherAPI+Response+CurrentObservation.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension YahooWeatherAPI.Response {
    struct CurrentObservation {
        let wind: Wind

        let atmosphere: Atmosphere

        let astronomy: Astronomy

        let condition: Condition

        let publicationDate: Date

        enum CodingKeys: String, CodingKey {
            case wind
            case atmosphere
            case astronomy
            case condition
            case publicationDate = "pubDate"
        }

        init(from decoder: Decoder, timeZone: TimeZone) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.wind = try values.decode(Wind.self, forKey: .wind)
            self.atmosphere = try values.decode(Atmosphere.self, forKey: .atmosphere)
            self.astronomy = try Astronomy(from: values.superDecoder(forKey: .astronomy), timeZone: timeZone)
            self.condition = try values.decode(Condition.self, forKey: .condition)

            let timeInterval = try TimeInterval(values.decode(Int.self, forKey: .publicationDate))
            self.publicationDate = Date(timeIntervalSince1970: timeInterval)
        }
    }
}
