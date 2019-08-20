//
//  YahooWeatherAPI+Response.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension YahooWeatherAPI {
    /// 응답
    struct Response: Decodable {
        /// 위치
        let location: Location

        /// 현재
        let currentObservation: CurrentObservation

        /// 예보
        let forecasts: [Forecast]

        enum CodingKeys: String, CodingKey {
            case location
            case currentObservation = "current_observation"
            case forecasts
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            let location = try values.decode(Location.self, forKey: .location)
            self.location = location
            self.currentObservation = try CurrentObservation(from: values.superDecoder(forKey: .currentObservation),
                                                             timeZone: location.timeZone)
            self.forecasts = try values.decode([Forecast].self, forKey: .forecasts)
        }

        enum Code: Int, Decodable {
            case tornado = 0
            case tropicalStorm = 1
            case hurricane = 2
            case severeThunderstorms = 3
            case thunderstorms = 4
            case mixedRainAndSnow = 5
            case mixedRainAndSleet = 6
            case mixedSnowAndSleet = 7
            case freezingDrizzle = 8
            case drizzle = 9
            case freezingRain = 10
            case showers = 11
            case rain = 12
            case snowFlurries = 13
            case lightSnowShowers = 14
            case blowingSnow = 15
            case snow = 16
            case hail = 17
            case sleet = 18
            case dust = 19
            case foggy = 20
            case haze = 21
            case smoky = 22
            case blustery = 23
            case windy = 24
            case cold = 25
            case cloudy = 26
            case mostlyCloudyNight = 27
            case mostlyCloudyDay = 28
            case partlyCloudyNight = 29
            case partlyCloudyDay = 30
            case clearNight = 31
            case sunny = 32
            case fairNight = 33
            case fairDay = 34
            case mixedRainAndHail = 35
            case hot = 36
            case isolatedThunderstorms = 37
            case scatteredThunderstorms = 38
            case scatteredShowersDay = 39
            case heavyRain = 40
            case scatteredSnowShowersDay = 41
            case heavySnow = 42
            case blizzard = 43
            case notAvailable = 44
            case scatteredShowersNight = 45
            case scatteredSnowShowersNight = 46
            case scatteredThundershowers = 47
        }
    }
}
