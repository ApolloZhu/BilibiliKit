//
//  BKVideo+Page.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation

extension BKVideo {
    /// Dimension of the video
    public struct Dimension: Codable {
        public let width: Int
        public let height: Int
        private let rotate: Int

        public var isVertical: Bool {
            return rotate != 0
        }
    }

    /// Sub page of video, identified by unique cid.
    public struct Page: Codable, Equatable {
        /// Unique identifier of this page.
        public let cid: Int

        /// Index of the page.
        public let page: Int
        /// Name of the page.
        public let pageName: String
        /// Length in seconds.
        public let duration: Int
        /// Video dimension.
        public let dimension: Dimension

        /// Where from, such as `vupload`.
        public let source: String
        /// ???
        public let vid: String
        ///???
        public let weblink: String

        /// Coding keys to use when encoding to other formats.
        enum CodingKeys: String, CodingKey {
            case cid, page, duration, dimension, vid, weblink
            case pageName = "part"
            case source = "from"
        }
        
        /// Check if two video pages are the same.
        ///
        /// - Parameters:
        ///   - lhs: A page of a video.
        ///   - rhs: Another page, of the same or another video.
        /// - Returns: true if they have the same cid, false otherwise.
        public static func ==(lhs: Page, rhs: Page) -> Bool {
            return lhs.cid == rhs.cid
        }
    }
}

// MARK: - Networking

extension BKVideo {
    /// Fetch all pages of video and perform action over.
    ///
    /// - Parameter handler: code to perform on the pages.
    public func pages(handler: @escaping BKHandler<[Page]>) {
        let url = "https://api.bilibili.com/x/player/pagelist?\(self)"
        URLSession.get(url, unwrap: BKWrapperMessage<[Page]>.self, then: handler)
    }

    /// Fetch the first page of video and perform action over.
    ///
    /// - Parameter handler: code to perform on the page.
    public func p1(handler: @escaping BKHandler<Page>) {
        pages { handler($0.map { $0.first! }) }
    }
    
    /// Fetch page of video at index and perform action over.
    ///
    /// - Parameters:
    ///   - index: **ONE** based index of the page to fetch.
    ///   - handler: code to perform on the page.
    public func page(_ index: Int, handler: @escaping BKHandler<Page>) {
        guard index > 0 else {
            return handler(.failure(.implementationError(
                reason: .invalidIndex(index))))
        }
        pages { result in
            handler(result.flatMap { pages in
                if index <= pages.count {
                    return .success(pages[index - 1])
                } else {
                    return .failure(.implementationError(reason: .invalidIndex(index)))
                }
            })
        }
    }
    
    /// Fetch page of video at index and perform action over.
    ///
    /// - Parameters:
    ///   - index: **ZERO** based index of the page to fetch.
    ///   - handler: code to perform on the page.
    public subscript(index: Int, handler: @escaping BKHandler<Page>) -> Void {
        page(index + 1, handler: handler)
    }
}
