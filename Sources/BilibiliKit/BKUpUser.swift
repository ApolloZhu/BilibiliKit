//
//  BKUpUser.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

/// Encapsulation for up related info.
public class BKUpUser: BKUser { }

extension BKUser {
    public var up: BKUpUser {
        return BKUpUser(id: mid)
    }
}
