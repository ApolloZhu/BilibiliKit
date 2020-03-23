//
//  BKArticle+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 5/11/18.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKArticle {
    public struct Info: Codable {
        /*
         /// 0.
         public let like: Int
         /// false.
         public let attention: Bool
         /// false.
         public let favorite: Bool
         /// 0.
         public let coin: Int
         */
        public struct Statistics: Codable {
            public let view: Int
            public let favorite: Int
            public let like: Int
            public let dislike: Int
            public let reply: Int
            public let share: Int
            public let coin: Int
        }
        /// Statistics about the article.
        public let statistics: Statistics
        /// Title of the article.
        public let title: String
        /// Cover image url.
        public let bannerURL: String
        /// Author id.
        public let mid: Int
        /// Author's name.
        public let author: String
        /// If the request was sent from the author.
        public let isAuthor: Bool
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
         /// false.
         public let in_list: Bool
         */
        enum CodingKeys: String, CodingKey {
            // case like, attention, favorite, coin
            case statistics = "stats"
            case title
            case bannerURL = "banner_url"
            case mid
            case author = "author_name"
            case isAuthor = "is_author"
            case croppedImageURLs = "image_urls"
            case originalImageURLs = "origin_image_urls"
            // case shareable, show_later_watch, show_small_window, in_list
        }
    }
}

extension BKArticle.Info {
    /// The actual cover image used.
    public var coverImageURL: URL {
        return URL(string: bannerURL)
            ?? originalImageURLs.first
            ?? croppedImageURLs.first
            ?? .notFound
    }
}

// MARK: - Networking

extension BKArticle {
    /// Fetchs and passes an article's info to `handler`.
    ///
    /// - Parameters:
    ///   - session: BKSession to generate request. Default to `BKSession.shared`.
    ///   - handler: code to process an optional `Info`.
    public func getInfo(withSession session: BKSession = .shared,
                        then handler: @escaping BKHandler<Info>) {
        URLSession.get("https://api.bilibili.com/x/article/viewinfo?id=\(id)",
            /// Error code or 0.
            /// Error description in Chinese.
            session: session, unwrap: BKWrapperMessage<Info>.self, then: handler)
    }
}
