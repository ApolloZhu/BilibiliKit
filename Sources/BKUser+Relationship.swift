//
//  BKUser+Relationship.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//

import Foundation

extension BKUser {
    public struct Relationship: Codable {
        // let mid: Int
        /// 关注数
        public let following: Int
        /// 悄悄关注
        public let whisper: Int
        /// 黑名单
        public let black: Int
        /// 粉丝数
        public let follower: Int
    }
}

extension BKUser {
    /// Handler type for relationships of a user fetched.
    ///
    /// - Parameter relationship: relationship fetched, `nil` if failed.
    public typealias RelationshipHandler = (_ relationship: Relationship?) -> Void

    /// Fetchs and passes this up's stat to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Stat`.
    public func getRelationshipHandler(then handler: @escaping RelationshipHandler) {
        let url = "https://api.bilibili.com/x/relation/stat?vmid=\(mid)"
        URLSession.get(url, unwrap: Wrapper<Relationship>.self, then: handler)
    }
}
