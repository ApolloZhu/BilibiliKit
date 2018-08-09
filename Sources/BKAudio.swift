//
//  BKAudio.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//

import Foundation

public struct BKAudio {
    /// Song id.
    public let sid: Int

    /// Initialize a song with its id.
    public init(au sid: Int) {
        self.sid = sid
    }
}

extension BKAudio {
    /// Wrapper for making network requests.
    struct Wrapper<Type>: BKWrapper, Codable where Type: Codable {
        /// 0 or error code.
        let code: Int
        /// "success" or error message.
        let msg: String
        /// Info or empty array.
        let data: Type?
    }
}
