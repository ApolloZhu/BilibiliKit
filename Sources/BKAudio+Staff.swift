//
//  BKAudio+Staff.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//

import Foundation

extension BKAudio {
    /// All members participated in making a song.
    ///
    /// - Note: When the uploader did everything,
    /// all the fields will be an empty string.
    public struct Staff: Codable {
        public let singer: String
        public let play: String
        public let bands: String
        /// 音源
        public let source: String
        /// 调音
        public let tuner: String
        /// 作曲
        public let composer: String
        /// 作词
        public let lyric: String
        /// 编曲
        public let arranger: String
        /// 后期/混音, I guess post means "after" here.
        public let post: String
        /// 封面制作
        public let cover: String
    }
}

extension BKAudio.Staff {
    /// If the staff list returned from bilibili API is valid.
    public var isEmpty: Bool {
        return singer.isEmpty
            && play.isEmpty
            && bands.isEmpty
            && source.isEmpty
            && tuner.isEmpty
            && composer.isEmpty
            && lyric.isEmpty
            && arranger.isEmpty
            && post.isEmpty
            && cover.isEmpty
    }
}

extension BKAudio {
    /// Handler type for participants of a song fetched.
    ///
    /// - Parameter staff: info fetched, `nil` if failed.
    public typealias StaffHandler = (_ staff: Staff?) -> Void

    /// Fetchs and passes this song's participants to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Staff`.
    public func getStaff(then handler: @escaping StaffHandler) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/member/song?sid=\(sid)"
        URLSession.get(url, unwrap: Wrapper<Staff>.self, then: handler)
    }
}
