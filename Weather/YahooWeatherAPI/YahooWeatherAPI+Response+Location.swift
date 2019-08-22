//
//  YahooWeatherAPI+Response+Location.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreLocation
import Foundation

extension YahooWeatherAPI.Response {
    /// 위치
    struct Location: Decodable {
        let woeid: Int

        let city: String

        let region: String

        let country: String

        let latitude: CLLocationDegrees

        let longitude: Double

        let timeZone: TimeZone

        enum CodingKeys: String, CodingKey {
            case woeid

            case city

            case region

            case country

            case latitude = "lat"

            case longitude = "long"

            case timeZone = "timezone_id"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.woeid = try values.decode(Int.self, forKey: .woeid)
            self.city = try values.decode(String.self, forKey: .city)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.region = try values.decode(String.self, forKey: .region)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.country = try values.decode(String.self, forKey: .country)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.latitude = try values.decode(CLLocationDegrees.self, forKey: .latitude)
            self.longitude = try values.decode(CLLocationDegrees.self, forKey: .longitude)
            self.timeZone = try {
                let timeZone: TimeZone! = try TimeZone(identifier: values.decode(String.self, forKey: .timeZone)
                    .trimmingCharacters(in: .whitespacesAndNewlines))
                assert(timeZone != nil)
                return timeZone
            }()
        }
    }
}
