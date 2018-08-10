//
//  BKAudio.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//

import Foundation

/// Bilibili song, identified by unique sid.
public struct BKAudio: Equatable {
    /// Song id.
    public let sid: Int

    /// Initialize a song with its id.
    public init(au sid: Int) {
        self.sid = sid
    }
}

extension BKAudio {
    /// Wrapper for making network requests.
    struct Wrapper<Wrapped: Codable>: BKWrapper, Codable {
        /// 0 or error code.
        let code: Int
        /// "success" or error message.
        let msg: String
        /// Info or empty array.
        let data: Wrapped?
    }
}
