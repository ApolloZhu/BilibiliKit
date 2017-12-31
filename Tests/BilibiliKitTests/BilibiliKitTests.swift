//
//  BilibiliKitTests.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/13/17.
//  Copyright © 2017 BilibiliKit. All rights reserved.
//

import XCTest
@testable import BilibiliKit

class BilibiliKitTests: XCTestCase {
    func testAppkeyFetching() {
        let goal = expectation(description: "Appkey fetch")
        BKApp.fetchKey {
            XCTAssertNotNil($0, "No Appkey")
            print("\n\($0!)\n")
            goal.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
    }

    func testVideoInfoFetching() {
        let goal = expectation(description: "Appkey fetch")
        BKVideo(av: 17794568).getInfo {
            XCTAssertNotNil($0, "No info")
            print()
            dump($0!)
            print()
            goal.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
    }

    func testVideoPageFetching() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let goal = expectation(description: "Video page information fetch")
        BKVideo(av: 8993458).p1 { page in
            XCTAssertNotNil(page, "Failed to fetch pages of video")
            XCTAssertEqual(page!.cid, 14848859, "Wrong cid")
            goal.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    static var allTests = [
        ("testAppkeyFetching", testAppkeyFetching),
        ("testVideoInfoFetching", testVideoInfoFetching),
        ("testVideoPageFetching", testVideoPageFetching)
    ]
}
