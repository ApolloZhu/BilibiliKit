//
//  RSA.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 3/23/20.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
#if canImport(BKFoundation)
import BKFoundation
#endif

#if canImport(Security)
import Security
#else
import _CryptoExtras
#endif

extension BKSec {
    private static let publicKeyBegin = "-----BEGIN PUBLIC KEY-----"
    private static let publicKeyEnd = "-----END PUBLIC KEY-----"

    /// Compute the digest using RSA PKCS1.
    ///
    /// - Copyright: Copyright (c) 2015 Scoop Technologies, Inc.
    /// [MIT License](https://github.com/TakeScoop/SwiftyRSA/blob/master/LICENSE).
    ///
    /// - Parameters:
    ///   - string: the data to be encrypted.
    ///   - publicKey: contents of a `.pem` file.
    public static func rsaEncrypt(
        _ string: String, with publicKey: String
    ) -> Result<String, BKError> {
        guard let stringData = string.data(using: .utf8) else {
            return .failure(.implementationError(reason: .invalidDataEncoding))
        }
        return encrypt(stringData, with: publicKey)
            .map { $0.base64EncodedString() }
    }

    #if canImport(Security)
    /// Calculates digest using RSA PCKS1.
    /// - Parameters:
    ///   - stringData: string to find digest for.
    ///   - keyData: public key data.
    private static func encrypt(
        _ stringData: Data, with publicKey: String
    ) -> Result<Data, BKError> {
        let publicKey = publicKey
            .replacingOccurrences(of: publicKeyBegin, with: "")
            .replacingOccurrences(of: publicKeyEnd, with: "")
            .replacingOccurrences(of: "\n", with: "")
        guard let keyData = Data(base64Encoded: publicKey) else {
            return .failure(.parseError(reason: .dataEncodeFailure))
        }

        var error: Unmanaged<CFError>? = nil
        var errorDescription: String {
            return (error!.takeRetainedValue() as Error).localizedDescription
        }
        guard let key = SecKeyCreateWithData(keyData as CFData, [
            kSecAttrType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: (keyData.count * 8) as NSNumber,
        ] as CFDictionary, &error) else {
            return .failure(.encryptError(
                reason: .publicKeyGenerationFailure(errorDescription)
            ))
        }
        guard SecKeyIsAlgorithmSupported(
            key, .encrypt, .rsaEncryptionPKCS1
        ) else {
            return .failure(.encryptError(
                reason: .rsaEncryptFailure(errorDescription)
            ))
        }
        guard let data = SecKeyCreateEncryptedData(
            key, .rsaEncryptionPKCS1, stringData as CFData, &error
        ) else {
            return .failure(.encryptError(
                reason: .rsaEncryptFailure(errorDescription)
            ))
        }
        return .success((data as Data))
    }
    #else
    private static func encrypt(
        _ stringData: Data, with publicKey: String
    ) -> Result<Data, BKError> {
        let key = _RSA.Signing.PublicKey(pemRepresentation: publicKey)
        #error("RSA implementation cannot encrypt with public key")
        return .failure(.encryptError(reason: .rsaEncryptFailure("NO ENCRYPTION BACKEND")))
    }
    #endif
}
