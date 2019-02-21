//
//  BKVideo+Page.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

import Foundation

extension BKVideo {
    /// Sub page of video, identified by unique cid.
    public struct Page: Codable, Equatable {
        /// AV number, the unique identifier of the container video.
        public fileprivate(set) var aid: Int!
        /// Index of the page.
        public let page: Int
        /// Name of the page.
        public let pageName: String
        /// Unique identifier of this page.
        public let cid: Int
        
        /// Coding keys to use when encoding to other formats.
        ///
        /// - page: page.
        /// - cid: cid.
        /// - pageName: pagename.
        /// - aid: aid, but doesn't matter since it's assigned.
        enum CodingKeys: String, CodingKey {
            case page, cid
            case pageName = "pagename"
            case aid
        }
        
        /// Check if two video pages are the same.
        ///
        /// - Parameters:
        ///   - lhs: A page of a video.
        ///   - rhs: Another page, of the same or another video.
        /// - Returns: true if they have the same cid, false otherwise.
        public static func ==(lhs: BKVideo.Page, rhs: BKVideo.Page) -> Bool {
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
        let pagesInfoURL = "https://www.bilibili.com/widget/getPageList?aid=\(aid)" as URL
        let task = URLSession.bk.dataTask(with: pagesInfoURL)
        { [aid] data,res,err in
            guard let data = data else {
                return handler(.failure(.responseError(
                    reason: .urlSessionError(err, response: res))))
            }
            handler(Result { try JSONDecoder().decode([Page].self, from: data) }
                .mapError { .parseError(reason: .jsonDecodeFailure($0)) }
                .flatMap { var pages = $0
                    guard !pages.isEmpty else {
                        return .failure(.responseError(reason: .emptyJSONResponse))
                    }
                    for index in pages.indices {
                        pages[index].aid = aid
                    }
                    return .success(pages)
            })
        }
        task.resume()
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
