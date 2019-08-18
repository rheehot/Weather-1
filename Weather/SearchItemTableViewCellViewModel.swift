//
//  SearchItemTableViewCellViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

class SearchItemTableViewCellViewModel: Hashable {
    static let reuseIdentifier = "SearchItemTableViewCellViewModel"

    static func == (lhs: SearchItemTableViewCellViewModel, rhs: SearchItemTableViewCellViewModel) -> Bool {
        return lhs.indexPath == rhs.indexPath &&
            lhs.location == rhs.location
    }

    let indexPath: IndexPath

    let location: LocationSearchManager.Location

    init(indexPath: IndexPath, location: LocationSearchManager.Location) {
        self.indexPath = indexPath
        self.location = location
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.indexPath)
        hasher.combine(self.location)
    }
}

extension SearchItemTableViewCellViewModel {
    convenience init(index: Int, location: LocationSearchManager.Location) {
        self.init(indexPath: IndexPath(row: index, section: 0), location: location)
    }
}
