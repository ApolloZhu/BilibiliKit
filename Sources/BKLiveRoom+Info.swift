//
//  BKLiveRoom+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 5/11/18.
//

import Foundation

extension BKLiveRoom {
    public struct Info: Codable {
        /// Author id.
        public let mid: Int
        public let roomID: Int
        public let shortID: Int
        /// Number of followers.
        public let followers: Int
        /// Number of current viewers.
        public let watching: Int
        public let isPortrait: Bool
        /// Description in HTML
        public let description: String
        /*
         let live_status: Int
         let area_id: Int
         let parent_area_id: Int
         // e.g. 娱乐.
         let parent_area_name: String
         let old_area_id: Int
         */
        public let background: String
        public let title: String
        /// Might be empty string.
        public let userChosenCoverImageURL: String
        public let keyframeSnapshotURL: URL
        // let is_strict_room: Bool
        /// When started. e.g. 2018-05-12 00:00:00
        // let live_time: String
        /// Tags. e.g. ACG音乐.
        public let tags: String
        /*
         let is_anchor: Int
         let room_silent_type: String
         /// Minumum level required to comment.
         let room_silent_level: Int
         /// Seconds before comment is enabled.
         let room_silent_second: Int
         /// Classification. e.g. 音乐台.
         public let area_name: String
         let pendants: String
         let area_pendants: String
         let hot_words: [String]
         */
        /// Verified official name.
        public let verifiedIdentity: String
        /*
         "new_pendants": {
         "frame": null,
         "badge": {
         "name": "v_company",
         "position": 3,
         "value": "",
         "desc": "哔哩哔哩直播 官方账号"
         },
         "mobile_frame": null,
         "mobile_badge": null
         },
         let up_session: String
         let allow_change_area_time: Int
         let allow_upload_cover_time: Int
         */
        
        enum CodingKeys: String, CodingKey {
            case mid = "uid"
            case roomID = "room_id"
            case shortID = "short_id"
            case followers = "attention"
            case watching = "online"
            case isPortrait = "is_portrait"
            case description, background, title
            case userChosenCoverImageURL = "user_cover"
            case keyframeSnapshotURL = "keyframe"
            case tags
            case verifiedIdentity = "verify"
        }
    }
}

extension BKLiveRoom.Info {
    /// The actual cover image in use.
    public var coverImageURL: URL {
        return URL(string: userChosenCoverImageURL) ?? keyframeSnapshotURL
    }
}

// MARK: - Networking

extension BKLiveRoom {
    private struct Wrapper: Codable {
        /// 0 or error code.
        let code: Int
        /// "ok" or error message.
        let msg: String
        /// "ok" or error message.
        let message: String
        /// Info or empty array.
        let data: Info?
    }
    
    /// Handler type for information of a live room fetched.
    ///
    /// - Parameter info: info fetched, `nil` if failed.
    public typealias InfoHandler = (_ info: Info?) -> Void
    
    /// Fetchs and passes a live room's info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info`.
    public func getInfo(then handler: @escaping InfoHandler) {
        let url = "https://api.live.bilibili.com/room/v1/Room/get_info?room_id=\(id)"
        let task = URLSession.bk.dataTask(with: URL(string: url)!)
        { data, _, _ in
            guard let data = data
                , let wrapper = try? JSONDecoder().decode(Wrapper.self, from: data)
                , let info = wrapper.data
                else { return handler(nil) }
            handler(info)
        }
        task.resume()
    }
}



