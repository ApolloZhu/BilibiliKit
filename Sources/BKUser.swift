//
//  BKUser.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//

public class BKUser {
    public let mid: Int

    public init(id mid: Int) {
        self.mid = mid
    }
}

extension BKUser {
    struct Wrapper<Wrapped: Codable>: BKWrapper, Codable {
        /// 0 or error code.
        let code: Int
        /// "0" or error message.
        let message: String
        // let ttl: Int // 1
        /// Info or empty array.
        let data: Wrapped?
    }
}
