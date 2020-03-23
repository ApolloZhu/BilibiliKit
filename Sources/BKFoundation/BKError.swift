//
//  BKError.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 2/10/19.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

public enum BKError: Error {
    public enum ParseErrorReason {
        case regexMatchNotFound
        case stringDecodeFailure
        case jsonDecode(Data, failure: Error)
        case dataEncodeFailure
    }
    public enum ResponseErrorReason {
        case urlSessionError(Error?, response: URLResponse?)
        case accessDenied
        case reason(String)
        case emptyJSONResponse
    }
    public enum ImplementationErrorReason {
        case invalidURL(String)
        case invalidRegex(Error)
        case invalidIndex(Int)
        case invalidDataEncoding
    }
    public enum EncryptionErrorReason {
        case publicKeySecKeyGenerationFailure(String)
        case rsaEncryptFailure(String)
    }
    
    case implementationError(reason: ImplementationErrorReason)
    case parseError(reason: ParseErrorReason)
    case responseError(reason: ResponseErrorReason)
    case encryptError(reason: EncryptionErrorReason)
}
