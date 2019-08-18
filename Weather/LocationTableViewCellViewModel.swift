//
//  LocationTableViewCellViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/18/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

class LocationTableViewCellViewModel: NSObject {
    static let reuseIdentifier = "LocationTableViewCellViewModel"

    let indexPath: IndexPath

    let location: Location

    init(indexPath: IndexPath, location: Location) {
        self.indexPath = indexPath
        self.location = location
        super.init()
    }

    override var hash: Int {
        return self.indexPath.hashValue ^ self.location.hashValue
    }
}

extension LocationTableViewCellViewModel {
    convenience init(index: Int, location: Location) {
        self.init(indexPath: IndexPath(row: index, section: 0), location: location)
    }
}
