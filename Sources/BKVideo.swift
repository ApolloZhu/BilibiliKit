//
//  BKVideo.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

/// Bilibili video, identified by unique av number (aid).
public struct BKVideo: Equatable {
    /// AV number, the unique identifier of the video.
    public let aid: Int
    
    /// Initialize a BKVideo with its av number.
    ///
    /// - Parameter aid: av number of the video.
    public init(av aid: Int) {
        self.aid = aid
    }
}
