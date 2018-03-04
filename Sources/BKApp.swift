//
//  BKApp.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

/// APPKEY associated operations
public enum BKApp {
    /// APPKEY from bilibili website.
    public static let appkey = "8e9fc618fbd41e28"
    
    // MARK: - Dynamic Fetching
    
    private static let regex = try? NSRegularExpression(pattern: "appkey=(.*?)&")
    private static let playerURL: URL = "https://www.bilibili.com/blackboard/player.html"
    
    /// Fetch a valid appkey from bilibili.
    ///
    /// - Parameter handler: code to run with fetched appkey.
    public static func fetchKey(_ handler: @escaping (String?) -> Void) {
        guard let regex = regex else { return handler(nil) }
        let task = URLSession.bk.dataTask(with: playerURL)
        { data, _, _ in
            guard let data = data
                , let raw = String(data: data, encoding: .utf8)
                else { return handler(nil) }
            let range = NSRange(raw.indices.startIndex..<raw.indices.endIndex, in: raw)
            guard let match = regex.matches(in: raw, range: range).first
                , let matchedRange = Range(match.range(at: 1), in: raw)
                else { return handler(nil) }
            let key = raw[matchedRange]
            handler("\(key)")
        }
        task.resume()
    }
}

