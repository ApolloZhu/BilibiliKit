//
//  BKVideo+Stat.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 3/23/20.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKVideo {
    public class _BaseStat: Codable {
        /// AV 号
        public let aid: Int
        /// 播放次数
        public let view: Int
        /// 弹幕数
        public let danmaku: Int
        /// 评论数
        public let reply: Int
        /// 收藏数
        public let favorite: Int
        /// 硬币数
        public let coin: Int
        /// 分享次数
        public let share: Int
        /// 点赞次数
        public let like: Int
        /// 现在排名
        public let now_rank: Int
        /// 历史最高排名
        public let his_rank: Int
        /// ???
        public let evaluation: String
    }

    public final class ArchiveStat: _BaseStat {
        /// BV 号
        public private(set) var bvid: String = ""
        /// ???
        public private(set) var argue_msg: String = ""
        /// 是否原创/自制？
        /// 1：自制
        /// 2：转载
        public private(set) var copyright: Int = -1
        /// 是否禁止转载
        public private(set) var no_reprint: Int = -1
    }

    public final class InfoStat: _BaseStat {
        /// 踩次数
        public private(set) var dislike: Int = 0
    }
}


extension BKVideo {
    public func getStat(then handler: @escaping BKHandler<ArchiveStat>) {
        let url = "https://api.bilibili.com/x/web-interface/archive/stat?\(self)"
        URLSession.get(url, unwrap: BKWrapperMessage<ArchiveStat>.self, then: handler)
    }

    /// In case if local conversion fails, this fetches the real IDs.
    ///
    /// - Parameter handler: process real aid and bvid
    public func getIDs(then handler: @escaping BKHandler<(aid: Int, bvid: String)>) {
        getStat { (result) in
            handler(result.map { (aid: $0.aid, bvid: $0.bvid) })
        }
    }
}
