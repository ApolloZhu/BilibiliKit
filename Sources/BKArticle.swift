//
//  BKArticle.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 5/11/18.
//

/// Bilibili article, identified by unique id.
struct BKArticle: Equatable {
    /// The unique identifier of the article.
    public let id: Int
    
    /// Initialize a BKArticle with its id.
    ///
    /// - Parameter id: number after cv of the article.
    public init(cv id: Int) {
        self.id = id
    }
}