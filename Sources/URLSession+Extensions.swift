//
//  URLSession+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

public protocol BKWrapper: Codable {
    associatedtype Wrapped: Codable
    var data: Wrapped? { get }
}

extension URLSession {
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    /// Shared url session, alias of URLSession.shared
    static var bk: URLSession { return .shared }
    #else
    /// Shared url session, replacement for URLSession.shared
    static let bk = URLSession(configuration: .default)
    #endif

    /// Fetches a decodable wrapper JSON and pass the unwrapped to handler.
    ///
    /// - Parameters:
    ///   - url: url to fetch.
    ///   - session: session containing cookie identifying current user.
    ///   - wrapperType: type containing `Wrapped` data field.
    ///   - handler: code to process an optional `Wrapped` instance.
    public class func get<Wrapper: BKWrapper>(
        _ url: String,
        session: BKSession = .shared,
        unwrap wrapperType: Wrapper.Type,
        then handler: @escaping (Wrapper.Wrapped?) -> Void)
    {
        guard let url = URL(string: url) else { return handler(nil) }
        let request = session.request(to: url)
        get(request, unwrap: wrapperType, then: handler)
    }

    /// Sends the request, unwraps the JSON, and pass the unwrapped to handler.
    ///
    /// - Parameters:
    ///   - request: request to complete.
    ///   - wrapperType: type containing `Wrapped` data field.
    ///   - handler: code to process an optional `Wrapped` instance.
    public class func get<Wrapper: BKWrapper>(
        _ request: URLRequest,
        unwrap wrapperType: Wrapper.Type,
        then handler: @escaping (Wrapper.Wrapped?) -> Void)
    {
        let task = URLSession.bk.dataTask(with: request) { data, _, _ in
            guard let data = data
                , let wrapper = try? JSONDecoder().decode(wrapperType, from: data)
                , let wrapped = wrapper.data
                else { return handler(nil) }
            handler(wrapped)
        }
        task.resume()
    }
}
