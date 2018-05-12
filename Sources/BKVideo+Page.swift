//
//  BKVideo+Page.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
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
    /// Handler type for all pages fetched.
    ///
    /// - Parameter pages: pages fetched, nil if failed or the video has no sub pages.
    public typealias PagesHandler = (_ pages: [Page]?) -> Void
    
    /// Fetch all pages of video and perform action over.
    ///
    /// - Parameter code: code to perform on the pages.
    public func pages(code: @escaping PagesHandler) {
        let pagesInfoURL = URL(string: "https://www.bilibili.com/widget/getPageList?aid=\(aid)")
        let task = URLSession.bk.dataTask(with: pagesInfoURL!)
        { [aid] data,_,_ in
            guard let data = data
                , var pages = try? JSONDecoder().decode([Page].self, from: data)
                , pages.count > 0
                else { return code(nil) }
            for index in pages.indices {
                pages[index].aid = aid
            }
            code(pages)
        }
        task.resume()
    }
    
    /// Handler type for single page fetched.
    ///
    /// - Parameter page: page fetched, nil if failed.
    public typealias PageHandler = (_ page: Page?) -> Void
    
    /// Fetch the first page of video and perform action over.
    ///
    /// - Parameter code: code to perform on the page.
    public func p1(code: @escaping PageHandler) {
        pages { code($0?.first) }
    }
    
    /// Fetch page of video at index and perform action over.
    ///
    /// - Parameters:
    ///   - index: **ONE** based index of the page to fetch.
    ///   - code: code to perform on the page.
    public func page(_ index: Int, code: @escaping PageHandler) {
        guard index > 0 else { return code(nil) }
        pages {
            guard let pages = $0
                , index <= pages.count
                else { return code(nil) }
            code(pages[index - 1])
        }
    }
    
    /// Fetch page of video at index and perform action over.
    ///
    /// - Parameters:
    ///   - index: **ZERO** based index of the page to fetch.
    ///   - code: code to perform on the page.
    public subscript(index: Int, code: @escaping PageHandler) -> Void {
        page(index + 1, code: code)
    }
}
