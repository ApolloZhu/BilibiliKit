//
//  BKAudio+Staff.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/8/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKAudio {
    public typealias StaffList = [Staff]
    public struct Staff: Codable {
        private struct Info: Codable {
            /// Might be 0
            let mid: Int
            let name: String
            // Might be an internal identifyer
            // public let member_id: Int
        }
        private let info: [Info]
        public let role: Role
        
        enum CodingKeys: String, CodingKey {
            case role = "type"
            case info = "list"
        }
    }
}

extension BKAudio.Staff: CustomStringConvertible {
    public var name: String {
        return info[0].name
    }
    
    public var mid: Int? {
        let mid = info[0].mid
        return mid == 0 ? nil : mid
    }
    
    public var description: String {
        return "\(role): \(name)\(mid.map { "(\($0))" } ?? "")"
    }
    
    /// All roles of members participated in making a song.
    ///
    /// - Note: When the uploader did everything,
    /// the `StaffList` only contains a single member of type 127.
    /// - Warning: Type 6 is missing, but what role it serves is unclear
    public enum Role: Int, Codable, CustomStringConvertible {
        /// 歌手
        case singer = 1
        /// 作词
        case lyric = 2
        /// 作曲
        case composer = 3
        /// 编曲
        case arranger = 4
        /// 后期/混音
        case postProduction = 5
        /// 封面制作
        case cover = 7
        /// 音源
        case source = 8
        /// 调音
        case tuner = 9
        /// 演奏
        case play = 10
        /// 乐器
        case bands = 11
        
        case iDidItAllMySelf = 127
        
        public var description: String {
            switch self {
            case .singer: return "歌手"
            case .lyric: return "作词"
            case .composer: return "作曲"
            case .arranger: return "编曲"
            case .postProduction: return "后期/混音"
            case .cover: return "封面制作"
            case .source: return "音源"
            case .tuner: return "调音"
            case .play: return "演奏"
            case .bands: return "乐器"
            case .iDidItAllMySelf: return "独立创作"
            }
        }
    }
}

extension BKAudio {
    /// Fetchs and passes this song's participants to `handler`.
    ///
    /// - Parameters:
    ///   - handler: code to process an optional `Staff`.
    public func getStaffList(then handler: @escaping BKHandler<StaffList>) {
        let url = "https://www.bilibili.com/audio/music-service-c/web/member/song?sid=\(sid)"
        URLSession.get(url, unwrap: BKWrapperMsg<StaffList>.self) { result in
            handler(result.flatMap { list in
                switch list.count {
                case 0:
                    return .failure(.responseError(reason: .emptyJSONResponse))
                case 1:
                    return .success(list)
                default:
                    return .success(list.filter { $0.role != .iDidItAllMySelf })
                }
            })
        }
    }
}
