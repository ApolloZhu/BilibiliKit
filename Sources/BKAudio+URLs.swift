//
//  BKAudio+URLs.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//

import Foundation

extension BKAudio {
    /// URLs and download info of a song
    public struct URLs: Codable {
        // let sid: Int
        // let type: Int
        // let info: String
        /// Valid interval.
        public let timeout: Int
        /// Download size.
        public let size: Int
        /// Download URLs.
        public let cdns: [URL]
    }
}

extension BKAudio {
    /// Handler type for urls of a song fetched.
    ///
    /// - Parameter urls: urls fetched, `nil` if failed.
    public typealias URLsHandler = (_ urls: URLs?) -> Void

    /// Fetchs and passes this song's download urls to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `URLs`.
    public func getURLs(then handler: @escaping URLsHandler) {
        // Maybe: privilege=2&quality=2
        let url = "https://www.bilibili.com/audio/music-service-c/web/url?sid=\(sid)"
        URLSession.get(url, unwrap: Wrapper<URLs>.self, then: handler)
    }
}
