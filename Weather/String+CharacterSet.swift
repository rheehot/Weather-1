//
//  String+CharacterSet.swift
//  Weather
//
//  Created by 진재명 on 8/16/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension String {
    init(characterSet: String, count: Int) {
        assert(count > 0)
        self.init((0 ..< count).compactMap { _ in characterSet.randomElement() })
    }
}
