//
//  URLSession+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

/// Generic handler type for all requests.
public typealias BKHandler<T> = (Result<T, BKError>) -> Void

public protocol BKWrapper: Codable {
    associatedtype Wrapped: Codable
    var data: Wrapped? { get }
    var message: String { get }
}

public struct BKWrapperMessage<Wrapped: Codable>: BKWrapper {
    public let code: Int
    public let message: String
    // let ttl: Int
    public let data: Wrapped?
}

public struct BKWrapperMsg<Wrapped: Codable>: BKWrapper {
    public let code: Int
    let msg: String
    // let ttl: Int
    public let data: Wrapped?
}

extension BKWrapperMsg {
    public var message: String { return msg }
}

extension URLSession {
    /// Shared url session, alias of URLSession.shared
    static var bk: URLSession { return .shared }

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
        then handler: @escaping (Result<Wrapper.Wrapped, BKError>) -> Void)
    {
        guard let _url = URL(string: url) else { return
            handler(.failure(.implementationError(reason: .invalidURL(url))))
        }
        let request = session.request(to: _url)
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
        then handler: @escaping (Result<Wrapper.Wrapped, BKError>) -> Void)
    {
        
        let task = URLSession.bk.dataTask(with: request) { data, res, err in
            guard let data = data else {
                return handler(.failure(.responseError(
                    reason: .urlSessionError(err, response: res))))
            }
            handler(Result { try JSONDecoder().decode(Wrapper.self, from: data) }
                .mapError { BKError.parseError(reason: .jsonDecodeFailure($0)) }
                .flatMap {
                    if let info = $0.data {
                        return .success(info)
                    } else {
                        return .failure(.responseError(reason: .reason($0.message)))
                    }})
        }
        task.resume()
    }
}
