//
//  SearchItemTableViewCellViewModel.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

class SearchItemTableViewCellViewModel: NSObject {
    let title: String

    let subtitle: String

    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}
