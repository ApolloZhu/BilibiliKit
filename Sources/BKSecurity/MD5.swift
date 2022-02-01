//
//  MD5.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/19/19.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
#if canImport(BKFoundation)
import BKFoundation
#endif

#if canImport(CryptoKit)
import CryptoKit
#elseif canImport(Crypto)
import Crypto
#endif

#if canImport(CommonCrypto)
import CommonCrypto
#endif

extension BKSec {
    /// Calculates digest using md5.
    /// - Parameters:
    ///   - string: the string to calculate md5 for.
    ///   - salt: salt to append after `string`. Defaults to `BKApp.salt`.
    public static func md5Hex(_ string: String, withSalt salt: String = BKApp.salt) -> Result<String, BKError> {
        guard let data = (string + salt).data(using: .utf8) else {
            return .failure(.parseError(reason: .dataEncodeFailure))
        }

        #if canImport(CommonCrypto)
            #if canImport(CryptoKit)
            if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *) {
                return md5Hex_CK(data)
            }
            #endif
            return md5Hex_CC(data)
        #elseif canImport(Crypto)
            return md5Hex_SC(data)
        #else
            #error("MD5: NO ENCRYPTION BACKEND")
        #endif
    }
}

extension Sequence where Element == UInt8 {
    /// Converts bytes to hex representation.
    var hexString: String {
        return reduce(into: "") { $0 += String(format: "%02hhx", $1) }
    }
}

extension BKSec {
    #if canImport(CryptoKit)
    /// Calculate MD5 using CryptoKit.
    /// - Parameter data: the data to run through md5.
    @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0,  *)
    static func md5Hex_CK(_ data: Data) -> Result<String, BKError> {
        return .success(Insecure.MD5.hash(data: data).hexString)
    }
    #endif

    #if !canImport(CryptoKit) && canImport(Crypto)
    /// Calculate MD5 using Swift Crypto.
    /// - Parameter data: the data to run through md5.
    static func md5Hex_SC(_ data: Data) -> Result<String, BKError> {
        return .success(Insecure.MD5.hash(data: data).hexString)
    }
    #endif

    #if canImport(CommonCrypto)
    /// Calculate MD5 using Common Crypto.
    ///
    /// - Author: [StackOverflow](https://stackoverflow.com/questions/32163848/how-can-i-convert-a-string-to-an-md5-hash-in-ios-using-swift/32166735#32166735)
    ///
    /// - Parameter data: the data to run through md5.
    @available(iOS, introduced: 2.0, deprecated: 13.0, message: "You should never see this warning.")
    @available(macOS, introduced: 10.4, deprecated: 10.15, message: "You should never see this warning.")
    @available(tvOS, introduced: 9.0, deprecated: 13.0, message: "You should never see this warning.")
    @available(watchOS, introduced: 2.0, deprecated: 6.0, message: "You should never see this warning.")
    static func md5Hex_CC(_ data: Data) -> Result<String, BKError> {
        var result = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { stringPtr in
            result.withUnsafeMutableBytes { resultPtr in
                _ = CC_MD5(stringPtr.baseAddress, CC_LONG(data.count),
                           resultPtr.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        return .success(result.hexString)
    }
    #endif
}
