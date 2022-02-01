//
//  BKUser+Relationship.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension BKUser {
    public struct Relationship: Codable {
        // let mid: Int
        /// 关注数
        public let following: Int
        /// 悄悄关注, only accurate if is current user
        public let whisper: Int
        /// 黑名单, only accurate if is current user
        public let black: Int
        /// 粉丝数
        public let follower: Int
    }
}

extension BKUser {
    /// Fetchs and passes this up's stat to `handler`.
    ///
    /// - Parameters:
    ///   - session: session logged in as. Default to `BKSession.shared`.
    ///   - handler: code to process an optional `Relationship`.
    public func getRelationship(session: BKSession = .shared,
                                then handler: @escaping BKHandler<Relationship>) {
        let url = "https://api.bilibili.com/x/relation/stat?vmid=\(mid)"
        URLSession.get(url, session: session,
                       unwrap: BKWrapperMessage<Relationship>.self,
                       then: handler)
    }
}
