//
//  BKApp.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

enum BKApp {
    private static let regex = try? NSRegularExpression(pattern: "appkey=(.*?)&")
    private static let playerURL: URL = "https://www.bilibili.com/blackboard/player.html"
    static func fetchKey(_ handler: @escaping (String?) -> Void) {
        guard let regex = regex else { return handler(nil) }
        let task = URLSession.bk.dataTask(with: playerURL)
        { data,_,_ in
            guard let data = data,
                let raw = String(data: data, encoding: .utf8)
                else { return handler(nil) }
            let range = NSRange(raw.indices.startIndex..<raw.indices.endIndex, in: raw)
            guard let match = regex.matches(in: raw, range: range).first,
                let matchedRange = Range(match.range(at: 1), in: raw)
                else { return handler(nil) }
            let key = raw[matchedRange]
            handler("\(key)")
        }
        task.resume()
    }
}

