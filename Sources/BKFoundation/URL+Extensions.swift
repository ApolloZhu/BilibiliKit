//
//  URL+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension URL: ExpressibleByStringInterpolation {
    /// Initialize url with string literals.
    ///
    /// - Parameter value: url.
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }

    @available(swift, deprecated: 3.0, obsoleted: 5.0, renamed: "inHTTPS")
    /// Deprecated, use `inHTTPS` instead.
    public var inHttps: URL? { return inHTTPS }

    /// Returns a new url with this url's scheme set to https,
    /// if the current url scheme is "http" or no scheme at all.
    public var inHTTPS: URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        if let scheme = components?.scheme {
            if scheme == "http" {
                components?.scheme = "https"
            }
        } else {
            components?.scheme = "https"
        }
        return components?.url
    }

    /// Pesudo `nil` value for URL where a non-optional URL is required
    public static let notFound: URL = "https://static.hdslb.com/images/akari.jpg"
}
