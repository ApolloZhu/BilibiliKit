//
//  URL+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

extension URL: ExpressibleByStringLiteral {    
    /// Initialize url with string literals.
    ///
    /// - Parameter value: url.
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }
    
    /// Set this url's scheme to https, if in http or no scheme.
    public var inHttps: URL? {
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
    
    public static let notFound: URL = "https://static.hdslb.com/images/akari.jpg"
}
