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
