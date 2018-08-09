//
//  BKCurrentUser.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 8/9/18.
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
