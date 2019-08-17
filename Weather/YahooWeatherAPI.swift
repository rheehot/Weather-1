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

    struct Response: Codable {}

    func query(location: CLLocationCoordinate2D, completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionTask {
        let endpoint: URL! = URL(string: "/forecastrss", relativeTo: self.baseURL)
        assert(endpoint != nil)

        var components: URLComponents! = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)
        assert(components != nil)

        let oauthItems: [String: String] = {
            let nonce = String(characterSet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", count: 16)

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
        }()

        let queryItems: [String: String] = {
            let formatter = NumberFormatter()
            formatter.usesSignificantDigits = true

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
        }()

        let signature: String = {
            let parameters = oauthItems.merging(queryItems, uniquingKeysWith: { current, _ in current })
                .sorted(by: { $0.key < $1.key })
                .map {
                    let key = $0.key.addingPercentEncoding(withAllowedCharacters: .rfc3986)
                    assert(key != nil)

                    let value = $0.value.addingPercentEncoding(withAllowedCharacters: .rfc3986)
                    assert(value != nil)

                    return "\(key!)=\(value!)"
                }
                .joined(separator: "&")
                .addingPercentEncoding(withAllowedCharacters: .rfc3986)
            assert(parameters != nil)
            os_log(.info, "%@", String(describing: parameters!))

            let url = components.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .rfc3986)
            assert(url != nil)
            os_log(.info, "%@", url!)

            let signatureBase = "GET&\(url!)&\(parameters!)"
            os_log(.info, "%@", signatureBase)

            return Data(signatureBase.utf8).hmacSHA1(secretKey: Data("\(self.clientSecret)&".utf8)).base64EncodedString()
        }()

        var request: URLRequest = {
            components.queryItems = queryItems.map(URLQueryItem.init)

            let url: URL! = components.url
            assert(url != nil)

            return URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        }()
        request.setValue(self.appID, forHTTPHeaderField: "X-Yahoo-App-Id")

        let authorization = oauthItems.merging(["oauth_signature": signature], uniquingKeysWith: { current, _ in current })
            .map { "\($0.key.addingPercentEncoding(withAllowedCharacters: .rfc3986)!)=\($0.value.addingPercentEncoding(withAllowedCharacters: .rfc3986)!)" }
            .joined(separator: ", ")

        request.setValue("OAuth \(authorization)", forHTTPHeaderField: "Authorization")

        os_log(.info, "%@", "\(request.allHTTPHeaderFields!)")

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

            os_log(.info, "%@", "\(data!)")

            completion(.success(Response()))
        }
        sessionTask.resume()

        return sessionTask
    }
}
