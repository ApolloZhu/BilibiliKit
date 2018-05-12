//
//  BKLiveRoom.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 5/11/18.
//

public struct BKLiveRoom {
    /// Either the short or actual id.
    public let id: Int
    
    /// Initialize a BKLiveRoom with one of its ids.
    ///
    /// - Parameter id: room id or short id.
    public init(_ id: Int) {
        self.id = id
    }
}
