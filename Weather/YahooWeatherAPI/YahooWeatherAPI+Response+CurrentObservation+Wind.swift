//
//  YahooWeatherAPI+Response+CurrentObservation+Wind.swift
//  Weather
//
//  Created by 진재명 on 8/19/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension YahooWeatherAPI.Response.CurrentObservation {
    /// 바람
    struct Wind: Decodable {
        /// 냉기
        let chill: Int

        /// 방향
        let direction: Int

        /// 풍속
        let speed: Double
    }
}
