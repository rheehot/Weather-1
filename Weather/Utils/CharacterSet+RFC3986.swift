//
//  CharacterSet+RFC3986.swift
//  Weather
//
//  Created by 진재명 on 8/16/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import Foundation

extension CharacterSet {
    static var rfc3986: CharacterSet {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.~")
        return characterSet
    }
}
