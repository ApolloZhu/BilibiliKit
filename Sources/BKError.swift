//
//  BKError.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 2/10/19.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

import Foundation

public enum BKError: Error {
    public enum ParseErrorReason {
        case regexMatchNotFound
        case stringDecodeFailure
        case jsonDecodeFailure(Error)
    }
    public enum ResponseErrorReason {
        case urlSessionError(Error?, response: URLResponse?)
        case reason(String)
        case emptyJSONResponse
    }
    public enum ImplementationErrorReason {
        case invalidURL(String)
        case invalidRegex(Error)
        case invalidIndex(Int)
    }
    
    case implementationError(reason: ImplementationErrorReason)
    case parseError(reason: ParseErrorReason)
    case responseError(reason: ResponseErrorReason)
}
