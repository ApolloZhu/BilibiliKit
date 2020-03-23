//
//  BKVideo.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

/// Bilibili video, identified by unique av number (aid).
public enum BKVideo {
    /// **[Deprecated]** Identify by aid.
    ///
    /// - Warning: consider using bvid instead:
    /// [【升级公告】AV号全面升级至BV号](bilibili.com/read/cv5167957).
    case av(Int)
    case bv(String)

    /// Initialize a BKVideo with its av number.
    /// - Warning: use bv instead [【升级公告】AV号全面升级至BV号](bilibili.com/read/cv5167957).
    /// - Parameter aid: av number of the video.
    @available(*, unavailable, renamed: "BKVideo.av(_:)", message: "Also consider using the new bvid instead (bilibili.com/read/cv5167957)")
    public init(av aid: Int) {
        self = .av(aid)
    }
}

extension BKVideo: CustomStringConvertible {
    public var description: String {
        switch self {
        case .av(let id):
            return "aid=\(id)"
        case .bv(let id):
            return "bvid=\(id)"
        }
    }
}

import Foundation

/// https://www.zhihu.com/question/381784377/answer/1099438784
extension BKVideo: Equatable {
    private static let itoc = Array("fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF")
    private static let ctoi = [Character: Int](uniqueKeysWithValues: zip(itoc, itoc.indices))
    private static let s = [11,10,3,8,4,6,2,9,5,7]
    private static let xor = 177451812
    private static let add = 100618342136696320

    public var aid: Int {
        switch self {
        case .av(let aid):
            return aid
        case .bv(let bvid):
            return BKVideo.av(fromBV: bvid)
        }
    }

    public var bvid: String {
        switch self {
        case .av(let aid):
            return BKVideo.bv(fromAV: aid)
        case .bv(let bvid):
            return bvid
        }
    }

    private static func exp(_ exp: Int) -> Int {
        return (pow(58, exp) as NSDecimalNumber).intValue
    }

    public static func bv(fromAV aid: Int) -> String {
        let aid = (aid ^ xor) + add
        var r = Array("BV          ")
        for i in 0..<10 {
            r[s[i]] = itoc[aid / exp(i) % 58]
        }
        return String(r)
    }

    public static func av(fromBV bvid: String) -> Int {
        var r = 0
        let bvid = Array(bvid)
        for i in 0..<10 {
            r += ctoi[bvid[s[i]]]! * exp(i)
        }
        return (r - add) ^ xor
    }

    public static func ==(lhs: BKVideo, rhs: BKVideo) -> Bool {
        switch (lhs, rhs) {
        case let (.av(id1), .av(id2)):
            return id1 == id2
        case let (.bv(id1), .bv(id2)):
            return id1 == id2
        default:
            return lhs.bvid == rhs.bvid
        }
    }
}
