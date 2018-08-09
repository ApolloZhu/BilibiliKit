//
//  URLSession+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

protocol BKWrapper {
    associatedtype Wrapped
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

    /// Fetchs and passes a wrapped codable to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Wrapped` instance.



    /// Fetches a decodable wrapper JSON and pass the wrapped to handler.
    ///
    /// - Parameters:
    ///   - url: url to fetch.
    ///   - wrapperType: type containing `Wrapped` data field.
    ///   - handler: code to process an optional `Wrapped` instance.
    class func get<Wrapper: BKWrapper & Decodable>(
        _ url: String, unwrap wrapperType: Wrapper.Type,
        then handler: @escaping (Wrapper.Wrapped?) -> Void
    ) {
        let task = URLSession.bk.dataTask(with: URL(string: url)!) { data, _, _ in
            guard let data = data
                , let wrapper = try? JSONDecoder().decode(wrapperType, from: data)
                , let wrapped = wrapper.data
                else { return handler(nil) }
            handler(wrapped)
        }
        task.resume()
    }
}
