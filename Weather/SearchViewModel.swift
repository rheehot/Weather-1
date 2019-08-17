//
//  SearchViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation
import MapKit

class SearchViewModel: NSObject {
    static let errorOccurredNotification = Notification.Name(rawValue: "SearchViewModel.errorOccurredNotification")

    static let errorUserInfoKey = "SearchViewModel.errorUserInfoKey"

    private let localSearchCompleter = MKLocalSearchCompleter()

    @objc dynamic var results: [SearchItemTableViewCellViewModel] = []

    override init() {
        super.init()

        self.localSearchCompleter.delegate = self
    }

    func search(query: String) {
        guard !query.isEmpty else {
            return
        }
        self.localSearchCompleter.queryFragment = query
    }
}

extension SearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.map { SearchItemTableViewCellViewModel(title: $0.title, subtitle: $0.subtitle) }
    }

    func completer(_: MKLocalSearchCompleter, didFailWithError error: Error) {
        NotificationCenter.default.post(name: SearchViewModel.errorOccurredNotification, object: self, userInfo: [
            SearchViewModel.errorUserInfoKey: error,
        ])
    }
}
