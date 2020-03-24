//
//  BKApp.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

/// APPKEY associated operations
public enum BKApp {
    /// APPKEY from bilibili website.
    public static let appkey = "4409e2ce8ffd12b8"
    public static let salt = "59b43e04ad6965f34319062b478f83dd"
    
    // MARK: - Dynamic Fetching
    
    private static let regex = try! NSRegularExpression(pattern: "appkey=([^&]+)&")
    private static let playerURL: URL = "https://www.bilibili.com/blackboard/player.html"
    
    /// Fetch a valid appkey from bilibili.
    ///
    /// - Parameter handler: code to run with fetched appkey.
    /// - Important: No salt (secret for this key).
    public static func fetchKey(_ handler: @escaping BKHandler<String>) {
        func raise(_ error: BKError) { handler(.failure(error)) }
        let task = URLSession._bk.dataTask(with: playerURL) { data, res, err in
            guard let data = data else {
                return raise(.responseError(
                    reason: .urlSessionError(err, response: res)))
            }
            guard let raw = String(data: data, encoding: .utf8) else {
                return raise(.parseError(reason: .stringDecodeFailure))
            }
            let range = NSRange(raw.startIndex..., in: raw)
            guard let match = regex.firstMatch(in: raw, range: range) else {
                return raise(.parseError(reason: .regexMatchNotFound))
            }
            let matchedRange = Range(match.range(at: 1), in: raw)!
            let key = raw[matchedRange]
            handler(.success("\(key)"))
        }
        task.resume()
    }
}
