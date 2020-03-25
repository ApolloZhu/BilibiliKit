//
//  BKUpUser+Stat.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

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
    ///   - handler: code to process an optional `Stat`.
    public func getStat(then handler: @escaping BKHandler<Stat>) {
        let url = "https://api.bilibili.com/x/space/upstat?mid=\(mid)"
        URLSession.get(url, unwrap: BKWrapperMessage<Stat>.self, then: handler)
    }
}
