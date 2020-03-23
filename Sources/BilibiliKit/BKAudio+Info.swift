//
//  BKAudio+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKAudio {
    /// Information of a song
    public struct Info: Codable {
        // id: sid
        /// Uploader user id
        public let uid: Int
        /// Uploader user name
        public let uname: String
        /// Song author
        public let author: String
        /// Song title
        public let title: String
        /// Cover image URL
        public let cover: URL
        /// Description
        public let intro: String
        /// Raw lyrics URL
        private let lyric: String
        // let crtype: Int
        /// Length in seconds
        public let duration: Int
        // let passtime: Int
        // let curtime: Int // current time
        /// AV number for related video
        public let aid: Int
        /// ID number for related video
        public let cid: Int
        // Not sure what these are
        // let msid: Int
        private let attr: Int
        private let limit: Int
        // let activityId: Int
        private let limitdesc: String
        // let ctime: Any?
        public struct Statistic: Codable {
            // let sid: Int
            public let play: Int
            public let collect: Int
            public let comment: Int
            public let share: Int
        }
        public let statistic: Statistic
        // let coin_num: Int?
    }
}

extension BKAudio.Info {
    /// Lyrics URL
    public var lyrics: URL? {
        return URL(string: lyric)
    }
}

extension BKAudio {
    /// Fetchs and passes this song's info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info`.
    public func getInfo(then handler: @escaping BKHandler<Info>) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/song/info?sid=\(sid)"
        /// "success" or error message.
        /// Info or empty array.
        URLSession.get(url, unwrap: BKWrapperMsg<Info>.self, then: handler)
    }
}
