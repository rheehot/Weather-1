//
//  Weather+Response.swift
//  Weather
//
//  Created by 진재명 on 8/21/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import Foundation

extension Weather {
    convenience init(context: NSManagedObjectContext, response: YahooWeatherAPI.Response) {
        self.init(context: context)

        self.woeid = response.location.woeid as NSNumber
        self.city = response.location.city
        self.region = response.location.region
        self.country = response.location.country
        self.latitude = response.location.latitude as NSNumber
        self.longitude = response.location.longitude as NSNumber
        self.timeZone = response.location.timeZone

        let converter = UnitTemperature.celsius.converter

        self.chill = converter.baseUnitValue(fromValue: Double(response.currentObservation.wind.chill)) as NSNumber
        self.direction = response.currentObservation.wind.direction as NSNumber
        self.speed = response.currentObservation.wind.speed as NSNumber

        self.humidity = response.currentObservation.atmosphere.humidity as NSNumber
        self.visibility = response.currentObservation.atmosphere.visibility as NSNumber
        self.pressure = response.currentObservation.atmosphere.pressure as NSNumber
        self.rising = response.currentObservation.atmosphere.rising.rawValue as NSNumber

        self.sunrise = response.currentObservation.astronomy.sunrise
        self.sunset = response.currentObservation.astronomy.sunset

        self.text = response.currentObservation.condition.text
        self.code = response.currentObservation.condition.code.rawValue as NSNumber

        self.temperature = converter.baseUnitValue(fromValue: Double(response.currentObservation.condition.temperature)) as NSNumber

        self.publicationDate = response.currentObservation.publicationDate

        self.forecasts = NSOrderedSet(array: response.forecasts.map { (forecast) -> Forecast in
            let managedObject = Forecast(context: context)

            managedObject.text = forecast.text
            managedObject.weekday = forecast.weekday.code as NSNumber
            managedObject.code = forecast.code.rawValue as NSNumber

            let converter = UnitTemperature.celsius.converter
            managedObject.highTemperature = converter.baseUnitValue(fromValue: Double(forecast.highTemperature)) as NSNumber
            managedObject.lowTemperature = converter.baseUnitValue(fromValue: Double(forecast.lowTemperature)) as NSNumber

            managedObject.date = forecast.date

            return managedObject
        })
    }
}
