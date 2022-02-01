//
//  BKUpUser+Stat.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension BKUpUser {
    /// Statistics of the user.
    public struct Stat: Codable {
        private struct View: Codable {
            /// The actual number
            fileprivate let view: Int
        }
        /// 视频播放数
        private let archive: View
        /// 文章阅读数
        private let article: View
        /// 获点赞数量
        public let likes: Int
    }
}

extension BKUpUser.Stat {
    /// 视频播放数
    public var videoPlaybackCount: Int {
        return archive.view
    }
    /// 文章阅读数
    public var articleViewCount: Int {
        return article.view
    }
}

extension BKUpUser {
    /// Fetchs and passes this up's stat to `handler`.
    ///
    /// - Parameters:
    ///   - session: session logged in as. Default to `BKSession.shared`.
    ///   - handler: code to process an optional `Stat`.
    public func getStat(session: BKSession = .shared,
                        then handler: @escaping BKHandler<Stat>) {
        let url = "https://api.bilibili.com/x/space/upstat?mid=\(mid)"
        URLSession.get(url, session: session,
                       unwrap: BKWrapperMessage<Stat>.self) { result in
            handler(result.mapError { error in
                if case let .parseError(reason: .jsonDecode(jsonData, _)) = error,
                   let json = try? JSONSerialization.jsonObject(with: jsonData),
                   let wrapperDict = json as? [String:Any],
                   let dataDict = wrapperDict["data"] as? [AnyHashable:Any],
                   dataDict.isEmpty {
                    return .responseError(reason: .emptyValue)
                }
                return error
            })
        }
    }
}
