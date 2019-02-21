//
//  BKUser.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

/// Bilibili user identified by mid/uid/whatever id.
public class BKUser {
    /// Member id.
    public let mid: Int

    /// Initialize a user with its id.
    public init(id mid: Int) {
        self.mid = mid
    }
}
