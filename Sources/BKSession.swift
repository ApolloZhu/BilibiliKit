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
    private let userDefaults: UserDefaults
    
    public var cookie: BKCookie? {
        get {
            guard let cached = userDefaults.data(forKey: cacheKey) else { return nil }
            return try? JSONDecoder().decode(BKCookie.self, from: cached)
        }
        set {
            userDefaults.set(try? JSONEncoder().encode(newValue), forKey: cacheKey)
            userDefaults.synchronize()
        }
    }
    
    private var cacheKey: String { return "\(BKCookie.filename)-\(identifier)" }
    
    public static let shared = BKSession(identifier: "__BILIBILI_KIT_DEFAULT_SESSION__")
    
    public init(identifier: String, cookie: BKCookie? = nil, userDefaults: UserDefaults = .standard) {
        self.identifier = identifier
        self.userDefaults = userDefaults
        self.cookie = cookie
    }
    
    public var isLoggedIn: Bool { return cookie != nil }
    
    public func logout() { cookie = nil }
    
    public func postRequest(to url: URL) -> URLRequest {
        var mutableRequest = request(to: url)
        mutableRequest.httpMethod = "POST"
        return mutableRequest
    }
    
    public func request(to url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("io.github.apollozhu.bilibilikit",
                         forHTTPHeaderField: "User-Agent")
        if let cookieHeader = cookie?.asHeaderField {
            request.addValue(cookieHeader,
                             forHTTPHeaderField: "Cookie")
        }
        return request
    }
}
