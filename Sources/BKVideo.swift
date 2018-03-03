//
//  BKVideo.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//

/// Bilibili video, identified by unique av number (aid).
public struct BKVideo: Equatable {
    /// AV number, the unique identifier of the video
    public let aid: Int
    
    /// Initialize a S2BVideo with its av number
    ///
    /// - Parameter aid: av number of the video
    public init(av aid: Int) {
        self.aid = aid
    }
    
    /// Check if two videos are the same.
    ///
    /// - Parameters:
    ///   - lhs: A video.
    ///   - rhs: Another video.
    /// - Returns: true if they have the same aid, false otherwise.
    public static func ==(lhs: BKVideo, rhs: BKVideo) -> Bool {
        return lhs.aid == rhs.aid
    }
}
