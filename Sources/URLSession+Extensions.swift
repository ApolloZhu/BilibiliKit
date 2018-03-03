//
//  URLSession+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

extension URLSession {
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    /// Shared url session, alias of URLSession.shared
    static var bk: URLSession { return .shared }
    #else
    /// Shared url session, replacement for URLSession.shared
    static let bk = URLSession(configuration: .default)
    #endif
}
