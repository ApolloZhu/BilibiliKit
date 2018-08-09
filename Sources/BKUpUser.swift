//
//  BKUpUser.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
//

/// Encapsulation for up related info.
public class BKUpUser: BKUser { }

extension BKUser {
    public var up: BKUpUser {
        return BKUpUser(id: mid)
    }
}
