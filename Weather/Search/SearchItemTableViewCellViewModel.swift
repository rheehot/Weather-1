//
//  SearchItemTableViewCellViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

struct SearchItemTableViewCellViewModel: Hashable {
    static let reuseIdentifier = "SearchItemTableViewCellViewModel.reuseIdentifier"

    static func == (lhs: SearchItemTableViewCellViewModel, rhs: SearchItemTableViewCellViewModel) -> Bool {
        return lhs.indexPath == rhs.indexPath && lhs.location == rhs.location
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.indexPath)
        hasher.combine(self.location)
    }

    let indexPath: IndexPath

    let location: SearchManager.Location

    init(indexPath: IndexPath, location: SearchManager.Location) {
        self.indexPath = indexPath
        self.location = location
    }

    init(index: Int, location: SearchManager.Location) {
        self.init(indexPath: IndexPath(row: index, section: 0), location: location)
    }
}
