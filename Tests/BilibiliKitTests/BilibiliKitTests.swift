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
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testVideoInfoFetching() {
        let goal = expectation(description: "Video info fetch")
        BKVideo(av: 170001).getInfo {
            XCTAssertNotNil($0, "No info")
            print()
            dump($0!)
            print()
            goal.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
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
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testAudioFail() {
        let audio = BKAudio(au: 0)
        let info = expectation(description: "Nonexisting audio info fetch")
        audio.getInfo {
            XCTAssertNil($0)
            info.fulfill()
        }
        let staff = expectation(description: "Nonexisting audio staff fetch")
        audio.getStaff {
            XCTAssertNotNil($0)
            XCTAssertTrue($0!.isEmpty)
            staff.fulfill()
        }
        let urls = expectation(description: "Nonexisting audio url fetch")
        audio.getURLs {
            XCTAssertNil($0)
            urls.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testAudioSingleFetching() {
        let audio = BKAudio(au: 195471)
        let info = expectation(description: "Single audio info fetch")
        audio.getInfo {
            XCTAssertNotNil($0)
            dump($0)
            XCTAssertNil($0?.lyrics)
            info.fulfill()
        }
        let staff = expectation(description: "Single audio staff fetch")
        audio.getStaff {
            XCTAssertNotNil($0)
            XCTAssertTrue($0!.isEmpty)
            staff.fulfill()
        }
        let urls = expectation(description: "Single audio url fetch")
        audio.getURLs {
            XCTAssertNotNil($0)
            dump($0)
            urls.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testCollaborativeAudioFetching() {
        let audio = BKAudio(au: 418827)
        let info = expectation(description: "Collaborative audio info fetch")
        audio.getInfo {
            XCTAssertNotNil($0)
            dump($0)
            XCTAssertNotNil($0!.lyrics)
            print($0!.lyrics!)
            info.fulfill()
        }
        let staff = expectation(description: "Collaborative audio staff fetch")
        audio.getStaff {
            XCTAssertNotNil($0)
            XCTAssertFalse($0!.isEmpty)
            dump($0)
            staff.fulfill()
        }
        let urls = expectation(description: "Collaborative audio url fetch")
        audio.getURLs {
            XCTAssertNotNil($0)
            dump($0)
            urls.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    static var allTests = [
        ("testAppkeyFetching", testAppkeyFetching),
        ("testVideoInfoFetching", testVideoInfoFetching),
        ("testVideoPageFetching", testVideoPageFetching),
        ("testAudioFail", testAudioFail),
        ("testAudioSingleFetching", testAudioSingleFetching),
        ("testCollaborativeAudioFetching", testCollaborativeAudioFetching)
    ]
}
