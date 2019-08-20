//
//  YahooWeatherAPI+Response+CurrentObservation+Atmosphere.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension YahooWeatherAPI.Response.CurrentObservation {
    /// 대기
    struct Atmosphere: Decodable {
        /// 습도
        let humidity: Int

        /// 가시거리
        let visibility: Double

        /// 기압
        let pressure: Double

        /// 기압 상태
        let rising: BarometricPressure

        enum CodingKeys: String, CodingKey {
            case humidity
            case visibility
            case pressure
            case rising
        }

        /// 기압상태
        ///
        /// - steady: 정상
        /// - rising: 상승
        /// - falling: 하강
        enum BarometricPressure: Int, Decodable {
            case steady = 0
            case rising = 1
            case falling = 2
        }
    }
}
