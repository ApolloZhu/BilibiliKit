//
//  URLSession+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

protocol BKWrapper: Codable {
    associatedtype Wrapped: Codable
    var data: Wrapped? { get }
}

//extension BKWrapper: Codable where Wrapped: Codable { }

extension URLSession {
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    /// Shared url session, alias of URLSession.shared
    static var bk: URLSession { return .shared }
    #else
    /// Shared url session, replacement for URLSession.shared
    static let bk = URLSession(configuration: .default)
    #endif

    /// Fetches a decodable wrapper JSON and pass the wrapped to handler.
    ///
    /// - Parameters:
    ///   - url: url to fetch.
    ///   - wrapperType: type containing `Wrapped` data field.
    ///   - isValid: only process if passes this test. Defaults to true.
    ///   - handler: code to process an optional `Wrapped` instance.
    class func get<Wrapper: BKWrapper>(
        _ url: String,
        unwrap wrapperType: Wrapper.Type,
        validate isValid: @escaping (Wrapper.Wrapped) -> Bool = { _ in true },
        then handler: @escaping (Wrapper.Wrapped?) -> Void
    ) {
        guard let url = URL(string: url) else { return handler(nil) }
        let task = URLSession.bk.dataTask(with: url) { data, _, _ in
            guard let data = data
                , let wrapper = try? JSONDecoder().decode(wrapperType, from: data)
                , let wrapped = wrapper.data
                , isValid(wrapped)
                else { return handler(nil) }
            handler(wrapped)
        }
        task.resume()
    }
}
