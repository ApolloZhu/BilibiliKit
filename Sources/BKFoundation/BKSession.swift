//
//  BKSession.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/15/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

/// Stores cookies of a session.
public class BKSession {
    /// To identify this session.
    public let identifier: String
    /// The user defaults where cookie is stored.
    private let userDefaults: UserDefaults
    
    /// The credential from bilibili.
    public var cookie: BKCookie? {
        get {
            guard let cached = userDefaults.data(forKey: cacheKey) else { return nil }
            return try? JSONDecoder().decode(BKCookie.self, from: cached)
        }
        set {
            guard let cookie = try? newValue.map(JSONEncoder().encode) else {
                return userDefaults.removeObject(forKey: cacheKey)
            }
            userDefaults.set(cookie, forKey: cacheKey)
        }
    }
    
    /// For user defaults.
    private var cacheKey: String { return "\(BKCookie.filename)-\(identifier)" }
    
    /// The shared session
    public static let shared = BKSession(identifier: "__BILIBILI_KIT_DEFAULT_SESSION__")
    
    /// Initialize a new session.
    ///
    /// - Parameters:
    ///   - identifier: to identify this session
    ///   - cookie: credential from bilibili to identify a user, default to `nil`.
    ///   - userDefaults: user defaults to save the cookie, default to `.standard`.
    public init(identifier: String, cookie: BKCookie? = nil, userDefaults: UserDefaults = .standard) {
        self.identifier = identifier
        self.userDefaults = userDefaults
        if let cookie = cookie {
            self.cookie = cookie
        }
    }
    
    /// If the current session has a user logged in.
    public var isLoggedIn: Bool { return cookie != nil }
    
    /// Clear stored cookie
    public func logout() { cookie = nil }
    
    /// Creates and returns a post request
    /// with cookie attached, if present.
    ///
    /// - Parameter url: the url to post to.
    /// - Returns: post request to url with optinal cookie.
    public func postRequest(to url: URL) -> URLRequest {
        var mutableRequest = request(to: url)
        mutableRequest.httpMethod = "POST"
        return mutableRequest
    }
    
    /// Creates and returns a general URLRequest
    /// with cookie attached, if present.
    ///
    /// - Parameter url: the url to request.
    /// - Returns: request to url with optional cookie.
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
