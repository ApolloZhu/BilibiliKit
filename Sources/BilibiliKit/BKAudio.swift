//
//  BKAudio.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

/// Bilibili song, identified by unique sid.
public struct BKAudio: Equatable {
    /// Song id.
    public let sid: Int

    /// Initialize a song with its id.
    public init(au sid: Int) {
        self.sid = sid
    }
}

// MARK: - Response Mapping

extension BKAudio {
    /// 版权受限
    internal static let accessDenied = 72010027
    /// 该音频不存在或已被下架
    internal static let removedOrNoExist = 7201006

    /// Maps generic `BKError.responseError` to a more specific one.
    /// - Parameter result: the response from `URLSession.get`.
    /// - Returns: result with error code correctly classified.
    fileprivate static func mapErrorCode<T>(_ result: BKResult<T>) -> BKResult<T> {
        return result.mapError { error in
            switch error {
            case .responseError(reason: .reason(_, code: let code)):
                switch code {
                case accessDenied:
                    return .responseError(reason: .accessDenied)
                case removedOrNoExist:
                    return .responseError(reason: .emptyValue)
                default:
                    return error
                }
            default:
                return error
            }
        }
    }

    /// Combines handler with preprocessor that wraps results' error code from bilibili audio.
    /// - Parameter handler: the handler from end user.
    /// - Returns: a new handler that preprocesses error code.
    internal static func middleware<T>(
        _ handler: @escaping BKHandler<T>
    ) -> BKHandler<T> {
        return { result in
            handler(mapErrorCode(result))
        }
    }
}
