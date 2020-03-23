//
//  BKCurrentUser.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

import Foundation

public final class BKCurrentUser: BKUpUser { }

extension BKUser {
    public class var current: BKUser? {
        if let mid = BKSession.shared.cookie?.mid {
            return BKUser(id: mid)
        }
        return nil
    }
}

//    public struct Level: Codable {
//        public let current: Int
//        public let currentExperience: Int
//        public let minExperience: Int
//        public let nextLevelMinExperience: Int
//
//        enum CodingKeys: String, CodingKey {
//            case current = "current_level"
//            case currentExperience = "current_min"
//            case minExperience = "current_exp"
//            case nextLevelMinExperience = "next_exp"
//        }
//
//        public struct Simple: Codable {
//            public let current: Int
//            enum CodingKeys: String, CodingKey {
//                case current = "current_level"
//            }
//        }
//    }
