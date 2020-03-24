//
//  BKError.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 2/10/19.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

/// All possible errors thrown by BilibiliKit.
public enum BKError: Error {
    /// bilibili changed their API. Contact @ApolloZhu to update BilibiliKit.
    public enum ParseErrorReason {
        case regexMatchNotFound
        case stringDecodeFailure
        case jsonDecode(Data, failure: Error)
        case dataEncodeFailure
    }
    /// bilibili or network is giving us some hard times.
    public enum ResponseErrorReason {
        case urlSessionError(Error?, response: URLResponse?)
        case accessDenied
        case reason(String)
        case emptyJSONResponse
        case emptyField
    }
    /// Either you or @ApolloZhu is making dumb mistakes.
    public enum ImplementationErrorReason {
        case invalidURL(String)
        case invalidRegex(Error)
        case invalidIndex(Int)
        case invalidDataEncoding
    }
    /// Security framework related errors.
    public enum EncryptionErrorReason {
        case publicKeySecKeyGenerationFailure(String)
        case rsaEncryptFailure(String)
    }
    
    case implementationError(reason: ImplementationErrorReason)
    case parseError(reason: ParseErrorReason)
    case responseError(reason: ResponseErrorReason)
    case encryptError(reason: EncryptionErrorReason)
}
