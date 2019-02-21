//
//  BKVideo+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

import Foundation

extension BKVideo {
    /// 视频相关信息
    /// - Warning: 不支持番剧
    public struct Info: Codable {
        // let tid: Int
        /// 分区
        public let type: String
        // let arctype: String // Copy
        /// 播放次数
        public let playTimesCount: Int
        /// 评论数
        public let reviewCount: Int
        /// 弹幕数
        public let danmakuCount: Int
        /// 收藏数
        public let favoritesCount: Int
        public let title: String
        /// 番剧为 1，普通为 0
        public let allow_bp: Int
        /// 目前只看到 0
        public let allow_feed: Int
        /// 目前只看到 0
        public let allow_download: Int
        /// 视频简介
        public let description: String
        // let tag: Any? // null
        /// 封面
        public let coverImageURL: URL
        
        /// UP 主名字
        public let author: String
        /// UP 主 mid
        public let mid: Int
        /// UP 主头像
        public let authorFaceURL: URL
        
        /// 分 p 数量
        public let pagesCount: Int
        // let instant_server: URL
        // let created: Int
        /// yyyy-MM-dd HH:mm
        public let creatAtTimestamp: String
        // let credit: String // --
        /// 硬币数
        public let coinsCount: Int
        // let spid: Any? // null
        // let src: String // c
        // Page specific, skip: let cid: Int
        // Page specific, skip: let partname: String
        // Page specific, skip: let part: String
        // let from: String // vupload
        // let type: String // vupload
        // let vid: String // vupload_\\d+?
        // let offsite: URL
        enum CodingKeys: String, CodingKey {
            case type = "typename"
            case playTimesCount = "play"
            case reviewCount = "review"
            case danmakuCount = "video_review"
            case favoritesCount = "favorites"
            case title
            /// Not sure yet
            case allow_bp, allow_feed, allow_download
            case description
            case coverImageURL = "pic"
            case author, mid
            case authorFaceURL = "face"
            case pagesCount = "pages"
            // let instant_server: URL
            // let created: Int
            case creatAtTimestamp = "created_at"
            case coinsCount = "coins"
        }
    }
}

// MARK: - Networking

extension BKVideo {
    /// Fetchs and passes this video's info to `handler`.
    ///
    /// - Parameter handler: code to process optional `Info`.
    public func getInfo(then handler: @escaping BKHandler<Info>) {
        BKVideo.getInfo(of: aid, withAppkey: BKApp.appkey) { [aid] result in
            guard case .failure = result else {
                return handler(result)
            }
            BKApp.fetchKey { result in
                switch result {
                case .success(let key):
                    BKVideo.getInfo(of: aid, withAppkey: key, then: handler)
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
    }
    
    /// Fetchs and passes a video's info to `handler`.
    ///
    /// - Parameters:
    ///   - aid: av number of the video.
    ///   - key: APPKEY from bilibili.
    ///   - handler: code to process optional `Info`.
    public static func getInfo(of aid: Int, withAppkey key: String, then handler: @escaping BKHandler<Info>) {
        let base = "https://api.bilibili.com/view?id=\(aid)&appkey=\(key)" as URL
        let task = URLSession.bk.dataTask(with: base)
        { data, res, err in
            guard let data = data else {
                return handler(.failure(.responseError(
                    reason: .urlSessionError(err, response: res))))
            }
            handler(Result { try JSONDecoder().decode(Info.self, from: data) }
                .mapError { .parseError(reason: .jsonDecodeFailure($0)) })
        }
        task.resume()
    }
}
