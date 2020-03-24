//
//  BKLiveRoom+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 5/11/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKLiveRoom {
    /// Information of a live room.
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
        /// Might be empty string
        public let keyframeSnapshotURL: String
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
         let hot_words_status: Int
         */
        /// Verified official name.
        public let verifiedIdentity: String
        /*
         "new_pendants": {
             "frame": {
                 "name": "",
                 "value": "",
                 "position": 0,
                 "desc": "",
                 "area": 0,
                 "area_old": 0,
                 "bg_color": "",
                 "bg_pic": "",
                 "use_old_area": false
             },
             "badge": null,
             "mobile_frame": {
                 "name": "",
                 "value": "",
                 "position": 0,
                 "desc": "",
                 "area": 0,
                 "area_old": 0,
                 "bg_color": "",
                 "bg_pic": "",
                 "use_old_area": false
             },
             "mobile_badge": null
         },
         "up_session": "",
         "pk_status": 0,
         "pk_id": 0,
         "battle_id": 0,
         "allow_change_area_time": 0,
         "allow_upload_cover_time": 0,
         "studio_info": {
             "status": 0,
             "master_list": []
         }
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
        return URL(string: userChosenCoverImageURL)
            ?? URL(string: keyframeSnapshotURL)
            ?? .notFound
    }
}

// MARK: - Networking

extension BKLiveRoom {
    /// Fetchs and passes this live room's info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info`.
    public func getInfo(then handler: @escaping BKHandler<Info>) {
        let url = "https://api.live.bilibili.com/room/v1/Room/get_info?room_id=\(id)"
        URLSession.get(url, unwrap: BKWrapperMessage<_Either<Info, [String]>>.self ) {
            handler($0.flatMap { either in
                switch either {
                case .left(let info):
                    return .success(info)
                case .right(let emptyArray):
                    return emptyArray.isEmpty
                        ? .failure(.responseError(reason: .emptyField))
                        : .failure(.parseError(reason: .dataEncodeFailure))
                }
            })
        }
    }
}
