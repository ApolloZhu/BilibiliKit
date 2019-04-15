//
//  BKSec.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 4/14/19.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

import Foundation
import Security
import CommonCrypto

enum BKSec {
    /// Copyright (c) 2015 Scoop Technologies, Inc.
    /// [MIT License](https://github.com/TakeScoop/SwiftyRSA/blob/master/LICENSE).
    static func rsaEncrypt(_ string: String, with publicKey: String) -> Result<String, BKError> {
        let publicKey = publicKey
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        var error: Unmanaged<CFError>? = nil
        guard let keyData = Data(base64Encoded: publicKey) else {
            return .failure(.parseError(reason: .dataEncodeFailure))
        }
        guard let key = SecKeyCreateWithData(keyData as CFData, [
            kSecAttrType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: (keyData.count * 8) as NSNumber,
        ] as CFDictionary, &error) else {
            return .failure(.encryptError(reason:
                .publicKeySecKeyGenerationFailure(String(describing: error))))
        }
        guard let stringData = string.data(using: .utf8) else {
            return .failure(.implementationError(reason: .invalidDataEncoding))
        }
        guard let data = SecKeyCreateEncryptedData(
            key, .rsaEncryptionPKCS1, stringData as CFData, &error) else {
            return .failure(.encryptError(reason:
                .rsaEncryptFailure(String(describing: error))))
        }
        return .success((data as Data).base64EncodedString())
    }
    
    // https://stackoverflow.com/questions/32163848/how-can-i-convert-a-string-to-an-md5-hash-in-ios-using-swift/32166735#32166735
    static func md5Hex(_ string: String, withSalt salt: String = BKApp.salt) -> Result<String, BKError> {
        var result = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        guard let data = (string + salt).data(using: .utf8) else {
            return .failure(.parseError(reason: .dataEncodeFailure))
        }
        data.withUnsafeBytes { stringPtr in
            result.withUnsafeMutableBytes { resultPtr in
                _ = CC_MD5(stringPtr.baseAddress, CC_LONG(data.count),
                           resultPtr.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        return .success(result.lazy.map { String(format: "%02hhx", $0) }.joined())
    }
}
