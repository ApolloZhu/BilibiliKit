//
//  BKAudio+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKAudio {
    /// Information of a song
    public struct Info: Codable {
        // id: sid
        /// Uploader user id
        public let mid: Int
        /// Uploader user name
        public let upName: String
        /// Song author
        public let author: String
        /// Song title
        public let title: String
        /// Cover image URL
        public let coverImageURL: URL
        /// Song description
        public let description: String
        /// Raw lyrics URL
        private let lyric: String
        /// Music type. 3 is video.
        public let crtype: Int
        /// Length in seconds.
        public let duration: Int
        /// Time interval since 1970 when passed review.
        public let passtime: Int
        // current time
        // private let curtime: Int
        /// AV number for related video. 0 if not exist.
        public let aid: Int
        /// BV ID string for related video, Empty if not exist.
        public let bvid: String
        /// ID number for related video. 0 if not exist.
        public let cid: Int
        // Not sure what these are:
        // ???
        // public let msid: Int
        /*
         t.isPGC && (t.intro = "该歌单为付费歌单，目前仅支持收听试听片段，请静候更多功能上线。"),
         t.isPGC = 5 === e.type,
         t.isLead = 2 === e.type,
         */
        /// Other bitmask flags.
        private let attr: Int
        /// Why audio is not available.
        private let limit: Int
        /// ???
        public let activityID: Int
        /// So far so empty. Let @ApolloZhu of any example.
        public let limitDescription: String
        // let ctime: null // 歌单 only
        /// Raw statistics.
        private let statistic: _Stat
        /// uploader's VIP information.
        public let upVIP: VIP
        /// VIP info.
        public struct VIP: Codable {
            /// 0: 不是大会员, 2: 年度大会员
            public let type: Int
            /// 0: 不是大会员, 1: 年度大会员
            private let status: Int
            /// 到期时间，1970 开始毫秒
            private let due_date: Int
            /// Please let me know what this is. So far I've only seen 0.
            public let vip_pay_type: Int

            /// Is currently 大会员.
            public var isActive: Bool {
                return status != 0
            }

            /// The date in which VIP status ends.
            public var dueDate: Date {
                return Date(timeIntervalSince1970: TimeInterval(due_date) / 1000)
            }
        }
        /// IDs of collections of the current users with this song.
        public let myCollectionIDs: [Int]
        /// I don't know why this isn't in stat, but fine
        private let coin: Int

        enum CodingKeys: String, CodingKey {
            case mid = "uid"
            case upName = "uname"
            case author, title
            case coverImageURL = "cover"
            case description = "intro"
            case lyric, crtype
            case duration, passtime, aid, bvid, cid
            case /*msid,*/ attr, limit, statistic
            case activityID = "activityId"
            case limitDescription = "limitdesc"
            case upVIP = "vipInfo"
            case myCollectionIDs = "collectIds"
            case coin = "coin_num"
        }
    }
}

// MARK: - Statistics

extension BKAudio {
    /// Audio statistics
    public struct Stat {
        /// 硬币数
        public let coin: Int
        /// 播放数
        public let play: Int
        /// 收藏数
        public let favorite: Int
        /// 回复/评论数
        public let reply: Int
        /// 分享次数
        public let share: Int
    }

    /// Raw statistics
    private struct _Stat: Codable {
        // let sid: Int
        /// 播放数
        fileprivate let play: Int
        /// 收藏数
        fileprivate let collect: Int
        /// 回复/评论数
        fileprivate let comment: Int
        /// 分享次数
        fileprivate let share: Int
    }
}

extension BKAudio.Info {
    /// Audio statistics.
    public var statistics: BKAudio.Stat {
        return BKAudio.Stat(
            coin: coin, play: statistic.play, favorite: statistic.collect,
            reply: statistic.comment, share: statistic.share
        )
    }

// MARK: - Lyrics

    /// Lyrics URL
    public var lyrics: URL? {
        return URL(string: lyric)
    }

    public var isVideo: Bool {
        return crtype == 3
    }

    /// Reasons why the audio is not available.
    public enum Limit: Int {
        /// 下架
        case discontinued = 1
        /// 版权受限
        case notLicensed
        /// 删除
        case deleted
    }

    /**
     Determine what limit is in place.

         isType: function(t, e) {
            return ("0000" + (+t).toString(2)).substr(-5).substring(e, e + 1)
         },

     - Parameters:
         - t: the bit masked integer.
         - limit: category to check (bit mask position, from left).
     - Returns: wether given t tests positive for the limit.
     */
    fileprivate func has(_ t: Int, _ limit: Int) -> Bool {
        let flag = 1 << (4 - limit)
        return (t & flag) != 0
    }

    /// Checks and returns if the audio is not available for some reason.
    /// - Parameter limitedBy: limit for why this audio is not available.
    /// - Returns: wether this audio has such limit.
    public func `is`(_ limitedBy: Limit) -> Bool {
        return has(limit, limitedBy.rawValue)
    }

    /// 付费歌曲试听片段
    public var isPreviewForPaidAudio: Bool {
        // t.isPGC = t.isType(n.attr, 1),
        return has(attr, 1)
    }
}

extension BKAudio {
    /// Fetchs and passes this song's info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info`.
    public func getInfo(then handler: @escaping BKHandler<Info>) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/song/info?sid=\(sid)"
        /// "success" or error message.
        /// Info or empty array.
        URLSession.get(url, unwrap: BKWrapperMsg<Info>.self,
                       then: BKAudio.middleware(handler))
    }
}
