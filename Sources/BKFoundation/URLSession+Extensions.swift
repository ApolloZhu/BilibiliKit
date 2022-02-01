//
//  URLSession+Extensions.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Generic result type for all requests.
public typealias BKResult<T> = Result<T, BKError>

/// Generic handler type for all requests.
public typealias BKHandler<T> = (BKResult<T>) -> Void

/// Codable response from bilibili.
public typealias BKWrapper = Decodable

/// Response by bilibili middleware
public protocol BKDataWrapper: BKWrapper {
    associatedtype Wrapped: Codable
    /// Actual data
    var data: Wrapped? { get }
}

/// Response by bilibili middleware, but with message
public protocol BKMessagedWrapper: BKWrapper {
    /// Response description.
    var message: String { get }
}

/// Response by bilibilib middleware, with code indicating type of error
public protocol BKCodeWrapper: BKWrapper {
    /// The status code, usually 0 for success and others for errors.
    var code: Int { get }
}

/// Response by bilibili middleware for errors.
public struct BKErrorResponse: BKMessagedWrapper, BKCodeWrapper, Error, LocalizedError {
    // let ts: Int
    /// Error code.
    public let code: Int
    /// Error message.
    public let message: String

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        return message
    }
}

/// Response by middleware where message is keyed as message.
public struct BKWrapperMessage<Wrapped: Codable>: BKDataWrapper, BKMessagedWrapper, BKCodeWrapper {
    /// Status code.
    public let code: Int
    /// Response description.
    public let message: String
    /// Actual data.
    public let data: Wrapped?
}

/// Response by middleware where message is keyed as msg.
public struct BKWrapperMsg<Wrapped: Codable>: BKDataWrapper, BKCodeWrapper {
    /// Status code.
    public let code: Int
    /// Response description.
    fileprivate let msg: String
    /// Actual data.
    public let data: Wrapped?
}

extension BKWrapperMsg: BKMessagedWrapper {
    /// Response description
    public var message: String { return msg }
}

extension URLSession {
    /// Shared url session, alias of URLSession.shared
    public static var _bk: URLSession { return .shared }

    /// Fetches a decodable wrapper JSON and pass the unwrapped to handler.
    ///
    /// - Parameters:
    ///   - url: url to fetch.
    ///   - session: session containing cookie identifying current user.
    ///   - wrapperType: type containing `Wrapped` data field.
    ///   - handler: code to process an optional `Wrapped` instance.
    public class func get<Wrapper: BKDataWrapper>(
        _ url: String,
        session: BKSession = .shared,
        unwrap wrapperType: Wrapper.Type,
        then handler: @escaping BKHandler<Wrapper.Wrapped>)
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
    public class func get<Wrapper: BKDataWrapper>(
        _ request: URLRequest,
        unwrap wrapperType: Wrapper.Type,
        then handler: @escaping BKHandler<Wrapper.Wrapped>)
    {
        let task = URLSession._bk.dataTask(with: request) { data, res, err in
            guard let data = data else {
                return handler(.failure(.responseError(
                    reason: .urlSessionError(err, response: res))))
            }
            handler(Result { try JSONDecoder().decode(Wrapper.self, from: data) }
                .mapError { BKError.parseError(reason: .jsonDecode(data, failure: $0)) }
                .flatMap { wrapper in
                    wrapper.data.map(Result<Wrapper.Wrapped, BKError>.success)
                        ?? (wrapper as? BKMessagedWrapper).map {
                            .failure(BKError.responseError(reason:
                                .reason($0.message,
                                        code: (wrapper as? BKCodeWrapper)
                                            .map { $0.code })))
                        }
                        ?? (wrapper as? BKCodeWrapper).map {
                            .failure(BKError.responseError(reason:
                                .reason("\($0.code)", code: $0.code)))
                        }
                        ?? .failure(BKError.responseError(reason: .emptyValue))
            })
        }
        task.resume()
    }
}
