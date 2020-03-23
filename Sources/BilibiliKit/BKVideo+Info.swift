//
//  BKVideo+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

public enum PlaybackCount: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let count = try container.decode(Int.self)
            self = .times(count)
        } catch {
            let string = try container.decode(String.self)
            if string == "--" {
                self = .notAvailable
            } else {
                throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                    codingPath: [], debugDescription:
                    #"Expecting either an integer or "--". Neither is found."#))
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .notAvailable:
            try container.encode("--")
        case .times(let count):
            try container.encode(count)
        }
    }
    
    case notAvailable
    case times(Int)
}


extension BKVideo {
    /// 视频相关信息
    public struct Info: Codable {
        enum CodingKeys: String, CodingKey {
            case bvid, aid, tid, copyright, title
            case pubdate, ctime, state, attribute
            case duration, rights, stat, dynamic
            case cid, dimension, no_cache, pages
            case type = "tname"
            case coverImageURL = "pic"
            case description = "desc"
            case author = "owner"
            case subtitles = "subtitle"
        }
        /// BV 号
        public let bvid: String
        /// AV 号
        public let aid: Int
        /// 分 P 数量
        @available(*, renamed: "pages.count")
        public var pagesCount: Int {
            return pages.count // "videos"
        }
        /// 分区 ID
        public let tid: Int
        /// 分区
        public let type: String
        /// 2: 转载
        private let copyright: Int
        /// 封面图，http
        public let coverImageURL: URL
        /// 标题
        public let title: String
        /// 发布时间
        private let pubdate: Int
        /// 创建时间
        private let ctime: Int
        /// 视频简介
        public let description: String
        /// 0
        private let state: Int
        /// ???
        private let attribute: Int
        /// 长度
        public let duration: Int
        /// 权限标记
        private let rights: Flags
        /// 0 不是 1 是
        private struct Flags: Codable {
            /// 是番剧
            let bp: Int
            /// 能充电
            let elec: Int
            /// 能下载
            let download: Int
            /// 是电影
            let movie: Int
            /// 需要付费观看（官方）
            let pay: Int
            /// ???
            let hd5: Int
            /// 禁止转载
            let no_reprint: Int
            /// 能自动播放
            let autoplay: Int
            /// 需要付费观看（用户）
            let ugc_pay: Int
            /// ???
            let is_cooperation: Int
            /// 是付费观看预览（用户）
            let ugc_pay_preview: Int
            /// 禁止后台播放
            let no_background: Int
        }
        /// UP 主
        public let author: Author
        public struct Author: Codable {
            /// UP 主 ID
            let mid: Int
            /// UP 主名字
            let name: String
            /// UP 主头像
            let faceURL: URL
            enum CodingKeys: String, CodingKey {
                case mid, name
                case faceURL = "face"
            }
        }
        public let stat: InfoStat
        /// 动态？
        public let dynamic: String
        public let cid: Int
        /// 视频尺寸
        public let dimension: Dimension
        /// ???
        private let no_cache: Bool
        /// 分 P
        public let pages: [Page]
        /// CC 字幕设置
        public let subtitles: Subtitles
        /// CC 字幕
        public struct Subtitle: Codable {
            public let id: Int
            /// Locale ID
            public let lan: String
            /// 语言
            public let lan_doc: String
            /// 锁定版本
            public let is_lock: Bool
            /// 链接
            public let subtitle_url: URL
            /// 作者
            public let author: Author
            /// Values defaults to 0 or 1
            public struct Author: Codable {
                public let mid: Int
                public let name: String
                public let sex: String
                public let face: String
                public let sign: String
                public let rank: Int
                public let birthday: Int
                public let is_fake_account: Int
                public let is_deleted: Int
            }
        }
        public struct Subtitles: Codable {
            /// 允许观众提交字幕
            let allow_submit: Bool
            let list: [Subtitle]

        }
    }

}

// MARK: Migration

extension BKVideo.Info {
    /// 创建时间
    public var creatAtTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = Date(timeIntervalSince1970: TimeInterval(ctime))
        return formatter.string(from: date)
    }
    /// UP 主 ID
    @available(*, renamed: "author.mid")
    public var mid: Int {
        return author.mid
    }
    /// UP 主头像
    @available(*, renamed: "author.faceURL")
    public var authorFaceURL: URL {
        return author.faceURL
    }
}

// MARK: - Networking

extension BKVideo {
    /// Fetchs and passes this video's info to `handler`.
    ///
    /// - Parameter cid: a specific page to process.
    /// - Parameter handler: code to process optional `Info`.
    public func getInfo(
        cid: Int? = nil,
        then handler: @escaping BKHandler<Info>
    ) {
        var url = "https://api.bilibili.com/x/web-interface/view?\(self)"
        if let cid = cid {
            url += "&cid=\(cid)"
        }
        URLSession.get(url, unwrap: BKWrapperMessage<Info>.self, then: handler)
    }
    
    /// Fetchs and passes a video's info to `handler`.
    ///
    /// - Parameters:
    ///   - aid: av number of the video.
    ///   - key: APPKEY from bilibili.
    ///   - handler: code to process optional `Info`.
    @available(*, renamed: "BKVideo.av.getInfo(then:)")
    public static func getInfo(
        of aid: Int, withAppkey key: String,
        in session: BKSession = .shared,
        then handler: @escaping BKHandler<Info>
    ) {
        return BKVideo.av(aid).getInfo(then: handler)
    }
}

