//
//  URL+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//  Copyright © 2017 BilibiliKit. All rights reserved.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Swift.StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }

    var inHttps: URL? {
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
}
