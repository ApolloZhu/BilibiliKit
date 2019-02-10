//
//  BKApp.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

public enum BKError: Error {
    public enum ParseErrorReason {
        case regexMatchNotFound
    }
    public enum ResponseErrorReason {
        case urlSessionError(Error?)
        case stringDecodeFailure
    }
    
    case implementationError(Error)
    case parseError(reason: ParseErrorReason)
    case responseError(reason: ResponseErrorReason)
}

/// APPKEY associated operations
public enum BKApp {
    /// APPKEY from bilibili website.
    public static let appkey = "8e9fc618fbd41e28"
    
    // MARK: - Dynamic Fetching
    
    private static let regex = Result { try NSRegularExpression(pattern: "appkey=(.*?)&") }
    private static let playerURL: URL = "https://www.bilibili.com/blackboard/player.html"
    
    /// Fetch a valid appkey from bilibili.
    ///
    /// - Parameter handler: code to run with fetched appkey.
    public static func fetchKey(_ handle: @escaping (Result<String, BKError>) -> Void) {
        let task = URLSession.bk.dataTask(with: playerURL) { data, _, err in
            handle(regex.mapError { .implementationError($0) }.flatMap { regex in
                guard let data = data else {
                    return .failure(.responseError(reason: .urlSessionError(err)))
                }
                guard let raw = String(data: data, encoding: .utf8) else {
                    return .failure(.responseError(reason: .stringDecodeFailure))
                }
                let range = NSRange(raw.indices.startIndex..<raw.indices.endIndex, in: raw)
                guard let match = regex.matches(in: raw, range: range).first else {
                    return .failure(.parseError(reason: .regexMatchNotFound))
                }
                let matchedRange = Range(match.range(at: 1), in: raw)!
                let key = raw[matchedRange]
                return .success("\(key)")
            })
        }
        task.resume()
    }
}
