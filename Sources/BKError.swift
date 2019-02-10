//
//  BKError.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 2/10/19.
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
    }
    
    case implementationError(Error)
    case parseError(reason: ParseErrorReason)
    case responseError(reason: ResponseErrorReason)
}
