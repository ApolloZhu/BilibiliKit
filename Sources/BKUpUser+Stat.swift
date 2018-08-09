//
//  BKUpUser+Stat.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//

import Foundation

extension BKUpUser {
    /// Statistics of the
    public struct Stat: Codable {
        private struct View: Codable {
            fileprivate let view: Int
        }
        private let archive: View
        private let article: View
    }
}

extension BKUpUser.Stat {
    /// 播放数
    public var archiveView: Int {
        return archive.view
    }
    /// 阅读数
    public var articleView: Int {
        return article.view
    }
}

extension BKUpUser {
    /// Handler type for stats of a up fetched.
    ///
    /// - Parameter stat: stat fetched, `nil` if failed.
    public typealias StatHandler = (_ stat: Stat?) -> Void

    /// Fetchs and passes this up's stat to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Stat`.
    public func getStat(then handler: @escaping StatHandler) {
        let url = "https://api.bilibili.com/x/space/upstat?mid=\(mid)"
        URLSession.get(url, unwrap: Wrapper<Stat>.self, then: handler)
    }
}
