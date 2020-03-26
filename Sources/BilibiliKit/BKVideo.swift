//
//  BKVideo.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

/// Bilibili video, identified by unique bv string (bvid) or [deprecated] av number (aid).
public enum BKVideo {
    /// **[Deprecated]** Video identified by av number (aid).
    ///
    /// - Warning: consider using bvid instead:
    /// [【升级公告】AV号全面升级至BV号](bilibili.com/read/cv5167957).
    case av(Int)
    /// Video identified by bv string (bvid).
    case bv(String)

    /// Initialize a BKVideo with its av number.
    /// - Warning: use bv instead [【升级公告】AV号全面升级至BV号](bilibili.com/read/cv5167957).
    /// - Parameter aid: av number of the video.
    @available(*, unavailable, renamed: "BKVideo.av(_:)", message: "Also consider using the new bvid instead (bilibili.com/read/cv5167957)")
    public init(av aid: Int) {
        self = .av(aid)
    }
}

// MARK: - URL Params

extension BKVideo: CustomStringConvertible {
    /// Useful to pass as URL parameter.
    public var description: String {
        switch self {
        case .av(let id):
            return "aid=\(id)"
        case .bv(let id):
            return "bvid=\(id)"
        }
    }
}

// MARK: - Local conversion between AV and BV

import Foundation

// https://www.zhihu.com/question/381784377/answer/1099438784
extension BKVideo: Equatable {
    /// Makes a sequences of bases in radix 58.
    fileprivate struct Exp: Sequence, IteratorProtocol {
        /// Next value to be returned
        private var current: Int64 = 1

        /// Advances to the next element and returns it.
        mutating func next() -> Int64? {
            defer { current *= 58 }
            return current
        }
    }

    /// Convert decimal number to radix 58.
    private static let itoc = Array("fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF")
    /// Convert radix 58 digits back to decimal.
    private static let ctoi = [Character: Int64](
        uniqueKeysWithValues: zip(itoc, itoc.indices.lazy.map(Int64.init))
    )
    /// The order in which digits are used.
    private static let indices = [11, 10, 3, 8, 4, 6, 2, 9, 5, 7]
    /// Modular so numbers are within bounds.
    private static let xor: Int64 = 177451812
    /// Shift by this magic number. Don't ask why.
    private static let add: Int64 = 100618342136696320

    /// The associated av number of this video.
    /// - Note: it's highly likely that an overflow will happen eventually. In that case, we crash.
    public var aid: Int {
        switch self {
        case .av(let aid):
            return aid
        case .bv(let bvid):
            return BKVideo.aid(fromBV: bvid)
        }
    }

    /// The associated bv string of this video.
    /// - Note: it's highly likely that an overflow will happen eventually. In that case, we crash.
    public var bvid: String {
        switch self {
        case .av(let aid):
            return BKVideo.bvid(fromAV: aid)
        case .bv(let bvid):
            return bvid
        }
    }

    /// Converts the given bv ID string to its corresponding av number.
    /// - Note: it's highly likely that an overflow will happen eventually. In that case, we crash.
    /// - Parameter bvid: the bv ID string to convert from.
    public static func aid(fromBV bvid: String) -> Int {
        var r: Int64 = 0
        let bvid = Array(bvid)
        for (i, exp) in zip(0..<10, Exp()) {
            r += ctoi[bvid[indices[i]]]! * exp
        }
        return Int((r - add) ^ xor)
    }

    /// Converts the given av number to its corresponding bv ID string.
    /// - Note: it's highly likely that an overflow will happen eventually. In that case, we crash.
    /// - Parameter aid: the av number to convert from.
    public static func bvid(fromAV aid: Int) -> String {
        let aid = (Int64(aid) ^ xor) + add
        var r = Array("BV          ")
        for (i, exp) in zip(0..<10, Exp()) {
            r[indices[i]] = itoc[Int(aid / exp % 58)]
        }
        return String(r)
    }

    /// Returns a Boolean value indicating whether two values are equal.
    /// Equality is the inverse of inequality. For any values a and b, a == b implies that a != b is false.
    /// 
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
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
