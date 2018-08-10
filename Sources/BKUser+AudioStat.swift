//
//  BKUser+AudioStat.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
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
    /// Handler type for audio stats of a user fetched.
    ///
    /// - Parameter audioStat: audio stat fetched, `nil` if failed.
    public typealias AudioStatHandler = (_ audioStat: AudioStat?) -> Void

    /// Fetchs and passes this up's audio stat to `handler`.
    ///
    /// - Important: Won't fail for invalid user.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `AudioStat`.
    public func getAudioStat(then handler: @escaping AudioStatHandler) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/stat/user?uid=\(mid)"
        URLSession.get(url, unwrap: BKAudio.Wrapper<AudioStat>.self, then: handler)
    }
}
