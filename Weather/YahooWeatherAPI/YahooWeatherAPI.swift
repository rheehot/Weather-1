//
//  YahooWeatherAPI.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreLocation
import Foundation
import os

class YahooWeatherAPI: NSObject {
    let baseURL: URL

    let appID: String

    let clientID: String

    let clientSecret: String

    let session = URLSession(configuration: .default)

    init(appID: String, clientID: String, clientSecret: String) {
        self.appID = appID
        self.clientID = clientID
        self.clientSecret = clientSecret

        let baseURL: URL! = URL(string: "https://weather-ydn-yql.media.yahoo.com")
        assert(baseURL != nil)
        self.baseURL = baseURL

        super.init()
    }

    func query(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionTask {
        return self.query(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), completion: completion)
    }

    func createOAuthItems() -> [String: String] {
        let nonce = String(randomStringFrom: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", count: 16)

        let formatter = NumberFormatter()

        let timestamp: String! = formatter.string(from: Date().timeIntervalSince1970 as NSNumber)
        assert(timestamp != nil)

        return [
            "oauth_consumer_key": self.clientID,
            "oauth_nonce": nonce,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": timestamp,
            "oauth_version": "1.0",
        ]
    }

    func createQueryItems(location: CLLocationCoordinate2D) -> [String: String] {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6

        let latitude: String! = formatter.string(from: location.latitude as NSNumber)
        assert(latitude != nil)

        let longitude: String! = formatter.string(from: location.longitude as NSNumber)
        assert(longitude != nil)

        return [
            "format": "json",
            "u": "c",
            "lat": latitude,
            "lon": longitude,
        ]
    }

    func createOAuthSignature(url: String, oauthItems: [String: String], queryItems: [String: String]) -> String {
        let parameters = oauthItems.merging(queryItems, uniquingKeysWith: { current, _ in current })
            .sorted(by: { $0.key < $1.key })
            .map(rfc3986Encoded)
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .rfc3986)
        assert(parameters != nil)

        let signatureBase = "GET&\(url)&\(parameters!)"

        return Data(signatureBase.utf8).hmacSHA1(secretKey: Data("\(self.clientSecret)&".utf8)).base64EncodedString()
    }

    func query(location: CLLocationCoordinate2D, completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionTask {
        let endpoint: URL! = URL(string: "/forecastrss", relativeTo: self.baseURL)
        assert(endpoint != nil)

        var components: URLComponents! = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)
        assert(components != nil)

        let oauthItems = self.createOAuthItems()

        let queryItems = self.createQueryItems(location: location)

        let url = components.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .rfc3986)
        assert(url != nil)

        let signature = self.createOAuthSignature(url: url!, oauthItems: oauthItems, queryItems: queryItems)

        var request: URLRequest = {
            components.queryItems = queryItems.map(URLQueryItem.init)

            let url: URL! = components.url
            assert(url != nil)

            return URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        }()

        request.setValue(self.appID, forHTTPHeaderField: "X-Yahoo-App-Id")

        let authorization = oauthItems.merging(["oauth_signature": signature],
                                               uniquingKeysWith: { current, _ in current })
            .map(rfc3986Encoded)
            .joined(separator: ", ")

        request.setValue("OAuth \(authorization)", forHTTPHeaderField: "Authorization")

        let sessionTask = self.session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }

            guard case 200 ..< 300 = response.statusCode else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            completion(Result {
                let decoder = JSONDecoder()

                return try decoder.decode(Response.self, from: data)
            })
        }
        sessionTask.resume()

        return sessionTask
    }
}

func rfc3986Encoded(key: String, value: String) -> String {
    let key = key.addingPercentEncoding(withAllowedCharacters: .rfc3986)
    assert(key != nil)

    let value = value.addingPercentEncoding(withAllowedCharacters: .rfc3986)
    assert(value != nil)

    return "\(key!)=\(value!)"
}
