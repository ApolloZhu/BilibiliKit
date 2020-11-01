//
//  BKArticle+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 5/11/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKArticle {
    /// Statistics about the article
    public struct Stat: Codable {
        /// Number of readers.
        public let view: Int
        /// Number of readers who favorited this.
        public let favorite: Int
        /// Number of readers who liked this.
        public let like: Int
        /// Number of readers who dislikes this.
        public let dislike: Int
        /// Number of comments.
        public let reply: Int
        /// Number of times shared.
        public let share: Int
        /// Number of coins received.
        public let coin: Int
        /// Number of dynamics that referenced this.
        public let dynamic: Int
    }

    /// Information about the article.
    public struct Info: Codable {
        /// If current user liked it. 0 no 1 yes.
        fileprivate let like: Int
        /// If current user follows the author.
        fileprivate let attention: Bool
        /// If current user favorited it.
        fileprivate let favorite: Bool
        /// Number of coins the current user give.
        fileprivate let coin: Int
        /// Statistics about the article.
        public let statistics: Stat
        /// Title of the article.
        public let title: String
        /// Cover image url.
        public let _bannerURL: String
        /// Author id.
        public let mid: Int
        /// Author's name.
        public let author: String
        /// If the request was sent from the author.
        private let isAuthor: Bool
        /// Cropped to show in the preview.
        public let croppedImageURLs: [URL]
        /// Actual images to display in article.
        public let originalImageURLs: [URL]
        /*
         /// true.
         public let shareable: Bool
         /// true.
         public let show_later_watch: Bool
         /// true.
         public let show_small_window: Bool
         */
        /// Is in a column collection.
        public let isInList: Bool
        /// Id of the previous article in the same column collection.
        public let previousArticleIDInList: Int
        /// Id of the next article in the same column collection.
        public let nextArticleIDInList: Int
        enum CodingKeys: String, CodingKey {
            case like, attention, favorite, coin
            case statistics = "stats"
            case title
            case _bannerURL = "banner_url"
            case mid
            case author = "author_name"
            case isAuthor = "is_author"
            case croppedImageURLs = "image_urls"
            case originalImageURLs = "origin_image_urls"
            // case shareable, show_later_watch, show_small_window
            case isInList = "in_list"
            case previousArticleIDInList = "pre"
            case nextArticleIDInList = "next"
        }
    }
}

extension BKArticle.Info {
    /// Info relevant to the current user about the article.
    public struct ForCurrentUser {
        /// If the current user is the author.
        public let isAuthor: Bool
        /// If current user liked the article.
        public let liked: Bool
        /// If current user follows the author.
        public let isFollowingAuthor: Bool
        /// If current user favorited it.
        public let favorited: Bool
        /// Number of coins the current user give.
        public let coin: Int
    }
    /// The data is only valid if `BKUser.current` exists.
    public var currentUser: ForCurrentUser {
        return ForCurrentUser(
            isAuthor: isAuthor, liked: like == 1,
            isFollowingAuthor: attention,
            favorited: favorite, coin: coin
        )
    }
}

extension BKArticle.Info {
    /// The actual cover image used.
    public var coverImageURL: URL {
        let urls = [URL(string: _bannerURL)] + originalImageURLs + croppedImageURLs
        return urls.lazy.compactMap { $0 }.first ?? .notFound
    }
}

// MARK: - Networking

extension BKArticle {
    /// Fetchs and passes an article's info to `handler`.
    ///
    /// - Parameters:
    ///   - session: session logged in as. Default to `BKSession.shared`.
    ///   - handler: code to process an optional `Info`, otherwise error description in Chinese.
    public func getInfo(withSession session: BKSession = .shared,
                        then handler: @escaping BKHandler<Info>) {
        URLSession.get("https://api.bilibili.com/x/article/viewinfo?id=\(id)",
                       session: session, unwrap: BKWrapperMessage<Info>.self,
                       then: handler)
    }
}
