//
//  YahooWeatherAPI+Response+CurrentObservation+Astronomy.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension YahooWeatherAPI.Response.CurrentObservation {
    struct Astronomy {
        /// 일출
        let sunrise: Date

        /// 일몰
        let sunset: Date

        enum CodingKeys: String, CodingKey {
            case sunrise
            case sunset
        }

        init(from decoder: Decoder, timeZone: TimeZone) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.defaultDate = Date()
            formatter.locale = Locale(identifier: "en")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"

            let sunrise: Date! = try formatter.date(from: values.decode(String.self, forKey: .sunrise))
            assert(sunrise != nil)
            self.sunrise = sunrise

            let sunset: Date! = try formatter.date(from: values.decode(String.self, forKey: .sunset))
            assert(sunset != nil)
            self.sunset = sunset
        }
    }
}
