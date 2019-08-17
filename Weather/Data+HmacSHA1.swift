//
//  Data+HmacSHA1.swift
//  Weather
//
//  Created by 진재명 on 8/16/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CommonCrypto
import Foundation

extension Data {
    func hmacSHA1(secretKey: Data) -> Data {
        return self.withUnsafeBytes { bytes in
            secretKey.withUnsafeBytes { secretKeyBytes in
                let encryptedMessage = UnsafeMutableRawPointer.allocate(byteCount: Int(CC_SHA1_DIGEST_LENGTH), alignment: 1)
                defer {
                    encryptedMessage.deallocate()
                }

                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
                       secretKeyBytes.baseAddress,
                       secretKeyBytes.count,
                       bytes.baseAddress,
                       bytes.count,
                       encryptedMessage)

                return Data(bytes: encryptedMessage, count: Int(CC_SHA1_DIGEST_LENGTH))
            }
        }
    }
}
