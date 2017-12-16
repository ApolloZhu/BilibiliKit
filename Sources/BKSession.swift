//
//  BKSession.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/15/17.
//  Copyright © 2017 BilibiliKit. All rights reserved.
//

import Foundation

public class BKSession {
    public let identifier: String
    
    public var cookie: BKCookie? {
        get {
            guard let cached = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
            return try? JSONDecoder().decode(BKCookie.self, from: cached)
        }
        set {
            UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: cacheKey)
        }
    }
    
    private var cacheKey: String { return "\(BKCookie.filename)-\(identifier)" }
    
    public static let shared = BKSession(identifier: "__BILIBILI_KIT_DEFAULT_SESSION__")
    
    public init(identifier: String, cookie: BKCookie? = nil) {
        self.identifier = identifier
        self.cookie = cookie
    }

    public var isLoggedIn: Bool { return cookie != nil }
    
    public func postRequest(to url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("io.github.apollozhu.bilibilikit", forHTTPHeaderField: "User-Agent")
        if let cookieHeader = cookie?.asHeaderField {
            request.addValue(cookieHeader, forHTTPHeaderField: "Cookie")
        }
        return request
    }
}

extension URL: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }
}
