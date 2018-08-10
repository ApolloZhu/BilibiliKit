//
//  BKUser+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//

import Foundation

extension BKUser {
    public struct Info: Codable {
        // let mid: Int
        private let name: String
        private let face: URL
        private let sign: String
        // Test case: 110352985
        /// 男，女，保密, ""
        private let sex: String
        // 10000 for normal, 20000 for bishi
        // let rank: Int
        // Might be in HTTP
        // Registration time
        private let regtime: Int
        // let spacesta: Int
        /// MM-dd
        public let birthday: String
        private let level_info: BKUser.Info.Level.Simple
        public struct Official: Codable {
            public let type: Int
            public let desc: String
            public let suffix: String
        }
        public let official_verify: Official
        public struct VIP: Codable {
            public let vipType: Int
            public let vipStatus: Int
        }
        public let vip: VIP
        /// Missing scheme and prefix, low resolution
        private let toutu: String
        /// Cover Image ID
        public let toutuId: Int
        // let theme: String // default
        // let theme_preview: String
        // let coins: Int
        // let im9_sign: String
        // let fans_badge: Bool
    }
}

extension BKUser.Info {
    public var basic: Basic {
        return Basic(name: name, avaterURL: face, bio: sign)
    }
    
    public var biologicalSex: BiologicalSex? {
        return BiologicalSex(rawValue: sex)
    }
    
    public var registrationTime: Date {
        return Date(timeIntervalSince1970: TimeInterval(regtime))
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
    
    public var birthdate: Date {
        return BKUser.Info.formatter.date(from: birthday)!
    }
    
    public var currentLevel: Int {
        return level_info.current
    }
    
    public var coverImageSmall: URL {
        return URL(string: "https://i0.hdslb.com/\(toutu)")!
    }
}

// MARK: - Components

extension BKUser.Info {
    public enum BiologicalSex: String, Codable {
        case male = "男"
        case female = "女"
        case secret = "保密"
    }
    
    public struct Level: Codable {
        public let current: Int
        public let currentExperience: Int
        public let minExperience: Int
        public let nextLevelMinExperience: Int
        
        enum CodingKeys: String, CodingKey {
            case current = "current_level"
            case currentExperience = "current_min"
            case minExperience = "current_exp"
            case nextLevelMinExperience = "next_exp"
        }
        
        public struct Simple: Codable {
            public let current: Int
            enum CodingKeys: String, CodingKey {
                case current = "current_level"
            }
        }
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
    /// Handler type for basic info of a user fetched.
    ///
    /// - Parameter info: basic information fetched, `nil` if failed.
    public typealias InfoHandler = (_ info: Info?) -> Void
    
    /// Fetchs and passes this user's info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info`.
    public func getInfo(then handler: @escaping InfoHandler) {
        let url = "https://space.bilibili.com/ajax/member/GetInfo" as URL
        var request = BKSession.shared.postRequest(to: url)
        request.addValue("https://space.bilibili.com",
                         forHTTPHeaderField: "Referer")
        request.httpBody = "mid=\(mid)".data(using: .utf8)
        struct PostWrapper: BKWrapper {
            let status: Bool
            let data: BKUser.Info?
        }
        URLSession.get(request, unwrap: PostWrapper.self, then: handler)
    }
    
    /// Handler type for basic info of a user fetched.
    ///
    /// - Parameter info: basic information fetched, `nil` if failed.
    public typealias BasicInfoHandler = (_ info: Info.Basic?) -> Void
    
    /// Fetchs and passes this user's basic info to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Info.Basic`.
    public func getBasicInfo(then handler: @escaping BasicInfoHandler) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/user/info?uid=\(mid)"
        URLSession.get(url, unwrap: BKAudio.Wrapper<Info.Basic>.self, then: handler)
    }
}
