//
//  BKArticle+Info.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 5/11/18.
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
    private struct Wrapper: Codable {
        /// Error code or 0.
        let code: Int
        /// Information if exists.
        let data: Info?
        /// Error description in Chinese.
        let message: String
        /// Usually 1.
        // let ttl: Int
    }
    
    /// Handler type for information of an article fetched.
    ///
    /// - Parameter info: info fetched, `nil` if failed.
    public typealias InfoHandler = (_ info: Info?) -> Void
    
    /// Fetchs and passes an article's info to `handler`.
    ///
    /// - Parameters:
    ///   - session: BKSession to generate request. Default to `BKSession.shared`.
    ///   - handler: code to process an optional `Info`.
    public func getInfo(withSession session: BKSession = .shared,
                        then handler: @escaping InfoHandler) {
        let baseURL = URL(string: "https://api.bilibili.com/x/article/viewinfo?id=\(id)")
        let request = session.request(to: baseURL!)
        let task = URLSession.bk.dataTask(with: request)
        { data, _, _ in
            guard let data = data
                , let wrapper = try? JSONDecoder().decode(Wrapper.self, from: data)
                , let info = wrapper.data
                else { return handler(nil) }
            handler(info)
        }
        task.resume()
    }
}
