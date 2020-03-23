//
//  BKUser+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKUser {
    /// Complete public user info.
    public struct Info: Codable {
        // let mid: Int
        private let name: String
        /// 男，女，保密, ""
        ///
        /// - Note: 110352985 is an interesting test case
        private let sex: String
        /// Might be in HTTP
        private let face: URL
        private let sign: String
        // 10000 for normal, 20000 for bishi, 5000 for 0
        // let rank: Int
        public let level: Int
        // Registration time, optional?
        private let jointime: Int?
        // let moral: Int
        // let silence: Int
        /// MM-dd
        public let birthday: String?
        // let coins: Double
        // let fans_badge: Bool
        public struct Official: Codable {
            public let role: Int
            public let desc: String
            public let title: String
        }
        public let official: Official
        public struct VIP: Codable {
            public let type: Int
            public let status: Int
        }
        public let vip: VIP
        private let is_followed: Bool
        /// Might be in HTTP
        private let top_photo: URL
        // let theme: Any
    }
}

extension BKUser.Info {
    /// Basic info.
    public var basic: Basic {
        return Basic(name: name, avaterURL: face, bio: sign)
    }

    /// 性别：男，女，保密, 或者没填写
    public var biologicalSex: BiologicalSex? {
        return BiologicalSex(rawValue: sex)
    }

    /// 注册日期
    ///
    /// - Note: HeadphoneTokyo 没有注册日期？
    public var registrationTime: Date? {
        guard let time = jointime else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(time))
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()

    /// 生日（月-日）
    public var birthdate: Date? {
        guard let birthday = birthday, !birthday.isEmpty else { return nil }
        return BKUser.Info.formatter.date(from: birthday)!
    }

    /// 用户等级
    @available(swift, deprecated: 5.0, renamed: "level")
    public var currentLevel: Int {
        return level
    }

    /// 小号头图
    @available(swift, deprecated: 5.0, renamed: "coverImage")
    public var coverImageSmall: URL {
        return coverImage
    }
    
    /// 头图
    public var coverImage: URL {
        return top_photo
    }
}

// MARK: - Components

extension BKUser.Info {
    public enum BiologicalSex: String, Codable {
        case male = "男"
        case female = "女"
        case secret = "保密"
    }
}

extension BKUser.Info {
    /// Essential user info that everyone cares about.
    public struct Basic: Codable {
        // let uid: Int
        /// 昵称
        public let name: String
        /// URL might be in http (especially for placeholder).
        public let avaterURL: URL
        /// 个性签名
        public let bio: String
        
        enum CodingKeys: String, CodingKey {
            case name = "uname"
            case avaterURL = "avater"
            case bio = "sign"
        }
    }
}

// MARK: - Networking

extension BKUser {
    /// Fetchs and passes this user's info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info`.
    public func getInfo(then handler: @escaping BKHandler<Info>) {
        URLSession.get("http://api.bilibili.com/x/space/acc/info?mid=\(mid)&jsonp=jsonp",
            unwrap: BKWrapperMessage<Info>.self, then: handler)
    }
    
    /// Fetchs and passes this user's basic info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info.Basic`.
    public func getBasicInfo(then handler: @escaping BKHandler<Info.Basic>) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/user/info?uid=\(mid)"
        URLSession.get(url, unwrap: BKWrapperMsg<Info.Basic>.self, then: handler)
    }
}
