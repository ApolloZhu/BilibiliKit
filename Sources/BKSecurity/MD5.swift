//
//  MD5.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/19/19.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
import BKFoundation

#if canImport(CryptoKit)
import CryptoKit
#elseif canImport(Crypto)
import Crypto
#else
#error("MD5: NO ENCRYPTION BACKEND")
#endif

#if canImport(CommonCrypto)
import CommonCrypto
#endif

extension BKSec {
    public static func md5Hex(_ string: String, withSalt salt: String = BKApp.salt) -> Result<String, BKError> {
        guard let data = (string + salt).data(using: .utf8) else {
            return .failure(.parseError(reason: .dataEncodeFailure))
        }

        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0,  *) {
            #if canImport(CryptoKit)
            return md5Hex_CK(data)
            #else
            #error("CryptoKit disappered")
            #endif
        } else {
            #if canImport(CommonCrypto)
            return md5Hex_CC(data)
            #else
            #error("CommonCrypto disappered")
            #endif
        }

        #if !canImport(CryptoKit) && canImport(Crypto)
        return md5Hex_SC(data)
        #endif
    }
}

extension Sequence where Element == UInt8 {
    var hexString: String {
        return reduce(into: "") { $0 += String(format: "%02hhx", $1) }
    }
}

extension BKSec {
    #if canImport(CryptoKit)
    @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0,  *)
    static func md5Hex_CK(_ data: Data) -> Result<String, BKError> {
        return .success(Insecure.MD5.hash(data: data).hexString)
    }
    #endif

    #if !canImport(CryptoKit) && canImport(Crypto)
    static func md5Hex_SC(_ data: Data) -> Result<String, BKError> {
        return .success(Insecure.MD5.hash(data: data).hexString)
    }
    #endif

    #if canImport(CommonCrypto)
    /// https://stackoverflow.com/questions/32163848/how-can-i-convert-a-string-to-an-md5-hash-in-ios-using-swift/32166735#32166735
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

