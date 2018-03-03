//
//  BKVideo+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/31/17.
//

import Foundation

extension BKVideo {
    /// 视频相关信息
    public struct Info: Codable {
        // let tid: Int
        /// 分区
        let type: String
        // let arctype: String // Copy
        /// 播放次数
        let playTimesCount: Int
        /// 评论数
        let reviewCount: Int
        /// 弹幕数
        let danmakuCount: Int
        /// 收藏数
        let favoritesCount: Int
        let title: String
        /// 番剧为 1，普通为 0
        let allow_bp: Int
        /// 目前只看到 0
        let allow_feed: Int
        /// 目前只看到 0
        let allow_download: Int
        /// 视频简介
        let description: String
        // let tag: Any? // null
        /// 封面
        let coverImageURL: URL
        
        /// UP 主名字
        let author: String
        /// UP 主 mid
        let mid: Int
        /// UP 主头像
        let authorFaceURL: URL
        
        /// 分 p 数量
        let pagesCount: Int
        // let instant_server: URL
        // let created: Int
        /// yyyy-MM-dd HH:mm
        let creatAtTimestamp: String
        // let credit: String // --
        /// 硬币数
        let coinsCount: Int
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
    
    /// Handler type for information about a video fetched.
    ///
    /// - Parameter info: info fetched, nil if failed.
    public typealias InfoHandler = (_ info: Info?) -> Void
    
    /// Fetchs and passes this video's info to `handler`.
    ///
    /// - Parameter handler: code to process optional `Info`.
    public func getInfo(then handler: @escaping InfoHandler) {
        BKVideo.getInfo(of: aid, withAppkey: BKApp.appkey) { [aid] info in
            guard info == nil else { return handler(info!) }
            BKApp.fetchKey {
                guard let key = $0 else { return handler(nil) }
                BKVideo.getInfo(of: aid, withAppkey: key, then: handler)
            }
        }
    }
    
    /// Fetchs and passes a video's info to `handler`.
    ///
    /// - Parameters:
    ///   - aid: av number of the video.
    ///   - key: APPKEY from bilibili.
    ///   - handler: code to process optional `Info`.
    public static func getInfo(of aid: Int, withAppkey key: String, then handler: @escaping InfoHandler) {
        let base = "https://api.bilibili.com/view?id=\(aid)&appkey=\(key)"
        let task = URLSession.bk.dataTask(with: URL(string: base)!)
        { data, _, _ in
            guard let data = data else { return handler(nil) }
            handler(try? JSONDecoder().decode(Info.self, from: data))
        }
        task.resume()
    }
}
