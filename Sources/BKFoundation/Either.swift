//
//  Either.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 3/24/20.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

public enum _Either<T, U> {
    case left(T)
    case right(U)
}

extension _Either: Codable where T: Codable, U: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let t = try container.decode(T.self)
            self = .left(t)
        } catch {
            do {
                let u = try container.decode(U.self)
                self = .right(u)
            } catch {
                throw DecodingError.typeMismatch(_Either<T, U>.self, .init(
                    codingPath: container.codingPath,
                    debugDescription: "Value in container is neither \(T.self) or \(U.self)"))
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .left(let t):
            try container.encode(t)
        case .right(let u):
            try container.encode(u)
        }
    }
}
