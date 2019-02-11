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
        BKApp.fetchKey { result in
            switch result {
            case .success(let key):
                print("\n\(key)")
                goal.fulfill()
            case .failure(let error):
                dump(error)
                XCTFail("No appkey")
            }
            print()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testVideoInfoFetching() {
        let goal = expectation(description: "Video info fetch")
        BKVideo(av: 170001).getInfo { result in
            switch result {
            case .success(let info):
                print()
                dump(info)
                print()
                goal.fulfill()
            case .failure(let error):
                XCTFail("No info for 170001, reason: \(error)")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testVideoPageFetching() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let goal = expectation(description: "Video page information fetch")
        BKVideo(av: 8993458).p1 { result in
            switch result {
            case .success(let page):
                XCTAssertEqual(page.cid, 14848859, "Wrong cid")
                goal.fulfill()
            case .failure(let error):
                XCTFail("Pages of video fetch failed, reason: \(error)")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testAudioFail() {
        let audio = BKAudio(au: 0)
        let info = expectation(description: "Nonexisting audio info fetch")
        audio.getInfo { result in
            guard case .failure = result else {
                return XCTFail("Valid info for invalid audio 0")
            }
            info.fulfill()
        }
        #warning("""
        let staff = expectation(description: "Nonexisting audio staff fetch")
        audio.getStaff {
            XCTAssertNotNil($0)
            XCTAssertTrue($0!.isEmpty)
            staff.fulfill()
        }
        """)
        let urls = expectation(description: "Nonexisting audio url fetch")
        audio.getURLs { result in
            guard case .failure = result else {
                return XCTFail("Valid url for invalid audio 0")
            }
            urls.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
        print()
    }

    func testAudioSingleFetching() {
        let audio = BKAudio(au: 195471)
        let info = expectation(description: "Single audio info fetch")
        audio.getInfo { result in
            switch result {
            case .success(let audioInfo):
                dump(audioInfo)
                XCTAssertNil(audioInfo.lyrics)
                info.fulfill()
            case .failure(let error):
                XCTFail("\(audio.sid) fetch failed, reason: \(error)")
            }
        }
        #warning(#"""
        let staff = expectation(description: "Single audio staff fetch")
        audio.getStaff {
            XCTAssertNotNil($0, "Failed to fetch audio \(audio.sid) staff")
            XCTAssertTrue($0!.isEmpty, "Random participants")
            staff.fulfill()
        }
        """#)
        let urls = expectation(description: "Single audio url fetch")
        audio.getURLs { result in
            switch result {
            case .success(let url):
                dump(url)
                urls.fulfill()
            case .failure(let error):
                XCTFail("\(audio.sid) download failed, reason: \(error)")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
        print()
    }

    func testCollaborativeAudioFetching() {
        let audio = BKAudio(au: 418827)
        let info = expectation(description: "Collaborative audio info fetch")
        audio.getInfo { result in
            switch result {
            case .success(let audioInfo):
                dump(audioInfo)
                XCTAssertNotNil(audioInfo.lyrics)
                print(audioInfo.lyrics!)
                info.fulfill()
            case .failure(let error):
                XCTFail("\(audio.sid) fetch failed, reason: \(error)")
            }
        }
        #warning(#"""
        let staff = expectation(description: "Collaborative audio staff fetch")
        audio.getStaff {
            XCTAssertNotNil($0, "Failed to fetch audio \(audio.sid) staff")
            XCTAssertFalse($0!.isEmpty, "Collaborators disappeared")
            dump($0!)
            staff.fulfill()
        }
        """#)
        let urls = expectation(description: "Collaborative audio url fetch")
        audio.getURLs { result in
            switch result {
            case .success(let url):
                dump(url)
                urls.fulfill()
            case .failure(let error):
                XCTFail("\(audio.sid) download failed, reason: \(error)")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
        print()
    }

    func testUserInfoFetching() {
        [0, 639647, 110352985, 14767902, 2].forEach { mid in
            print("BEGIN \(mid)")
            let user = BKUpUser(id: mid)
            let basicInfo = expectation(description: "Basic Info of \(mid)")
            user.getBasicInfo { result in
                switch result {
                case .success(let info):
                    dump(info)
                    print()
                case .failure(let error):
                    XCTAssertEqual(mid, 0, "Basic Info \(mid) fetch failed, reason: \(error)")
                }
                basicInfo.fulfill()
            }
            let info = expectation(description: "Info of \(mid)")
            user.getInfo { result in
                switch result {
                case .success(let i):
                    dump(i)
                    print(i.biologicalSex ?? "No biological sex")
                    print(i.birthdate ?? "No birthday")
                    print(i.registrationTime ?? "Not registered normally")
                    print(i.coverImage)
                    print(i.level)
                case .failure(let error):
                    XCTAssertEqual(mid, 0, "Info of \(mid) fetch failed, reason: \(error)")
                }
                print()
                info.fulfill()
            }
            let relation = expectation(description: "Relationship of \(mid)")
            user.getRelationship { result in
                switch result {
                case .success(let relationship):
                    dump(relationship)
                    print()
                case .failure(let error):
                    XCTAssertEqual(mid, 0, "User \(mid) relationship fetch failed, reason: \(error)")
                }
                relation.fulfill()
            }
            let audioStat = expectation(description: "Audio stat of \(mid)")
            user.getAudioStat { result in
                switch result {
                case .success(let audioStat):
                    dump(audioStat)
                case .failure(let error):
                    print(error)
                }
                print()
                audioStat.fulfill()
            }
            let upStat = expectation(description: "Up stat of \(mid)")
            user.getStat { result in
                switch result {
                case .success(let stat):
                    dump(stat)
                    print()
                case .failure(let error):
                    XCTAssertEqual(mid, 0, "Up\(mid) stat fetch failed, reason: \(error)")
                }
                upStat.fulfill()
            }
            waitForExpectations(timeout: 300, handler: nil)
            print("--END \(mid)")
            print()
            print()
        }
    }

    static var allTests = [
        ("testAppkeyFetching", testAppkeyFetching),
        ("testVideoInfoFetching", testVideoInfoFetching),
        ("testVideoPageFetching", testVideoPageFetching),
        ("testAudioFail", testAudioFail),
        ("testAudioSingleFetching", testAudioSingleFetching),
        ("testCollaborativeAudioFetching", testCollaborativeAudioFetching),
        ("testUserInfoFetching", testUserInfoFetching)
    ]
}
