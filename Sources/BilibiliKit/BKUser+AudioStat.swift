//
//  BKUser+AudioStat.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKUser {
    public struct AudioStat: Codable {
        /// Number audio creations played
        public let play: Int
        /// Number of audio creations listend to
        public let listen: Int
        /// Number of fans
        public let fans: Int
        /// Number of audio creations
        public let creations: Int
    }
}

extension BKUser {
    /// Fetchs and passes this up's audio stat to `handler`.
    ///
    /// - Important: Won't fail for invalid user.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `AudioStat`.
    public func getAudioStat(then handler: @escaping BKHandler<AudioStat>) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/stat/user?uid=\(mid)"
        URLSession.get(url, unwrap: BKWrapperMsg<AudioStat>.self, then: handler)
    }
}
