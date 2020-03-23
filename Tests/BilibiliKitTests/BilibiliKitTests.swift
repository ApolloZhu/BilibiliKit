//
//  BilibiliKitTests.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/13/17.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

#if !os(watchOS)
import XCTest
@testable import BilibiliKit

class BilibiliKitTests: XCTestCase {
    func testAppkeyFetching() {
        let goal = expectation(description: "Appkey fetch")
        BKApp.fetchKey { result in
            defer { goal.fulfill() }
            switch result {
            case .success(let key):
                print("\n\(key)")
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
            defer { goal.fulfill() }
            switch result {
            case .success(let info):
                print()
                dump(info)
                print()
            case .failure(let error):
                XCTFail("No info for 170001, reason: \(error)")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testHiddenVideoInfoFetching() {
        let goal = expectation(description: "Hidden video info fetch")
        func fetchHiddenVideo() {
            BKVideo(av: 5510557).getInfo { result in
                defer { goal.fulfill() }
                switch result {
                case .success(let info):
                    print()
                    dump(info)
                    print()
                case .failure(let error):
                    XCTFail("No info for 5510557, reason: \(error)")
                }
            }
        }
        if BKSession.shared.isLoggedIn {
            fetchHiddenVideo()
        } else {
            let ENV = ProcessInfo.processInfo.environment
            if ENV["GITHUB_TOKEN"]?.isEmpty == false {
                print("Skipping on Travis CI if not already logged in")
                goal.fulfill()
            } else {
                BKSession.shared.login(ENV["BILI_USER"]!, password: ENV["BILI_PASS"]!) {
                    dump($0)
                    fetchHiddenVideo()
                }
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
            defer { goal.fulfill() }
            switch result {
            case .success(let page):
                XCTAssertEqual(page.cid, 14848859, "Wrong cid")
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
            defer { info.fulfill() }
            guard case .failure = result else {
                return XCTFail("Valid info for invalid audio 0")
            }
        }
        let staff = expectation(description: "Nonexisting audio staff fetch")
        audio.getStaffList { result in
            defer { staff.fulfill() }
            switch result {
            case .failure(let error):
                print("Successfully errored: \(error)")
            case .success(let list):
                XCTFail("Found \(list) while no staff is expected")
            }
        }
        let urls = expectation(description: "Nonexisting audio url fetch")
        audio.getURLs { result in
            defer { urls.fulfill() }
            guard case .failure = result else {
                return XCTFail("Valid url for invalid audio 0")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
        print()
    }

    func testAudioSingleFetching() {
        let audio = BKAudio(au: 195471)
        let info = expectation(description: "Single audio info fetch")
        audio.getInfo { result in
            defer { info.fulfill() }
            switch result {
            case .success(let audioInfo):
                dump(audioInfo)
                XCTAssertNil(audioInfo.lyrics)
            case .failure(let error):
                XCTFail("\(audio.sid) fetch failed, reason: \(error)")
            }
        }
        let staff = expectation(description: "Single audio staff fetch")
        audio.getStaffList { result in
            defer { staff.fulfill() }
            switch result {
            case .success(let list):
                XCTAssertEqual(list.count, 1, "Multiple staff found where 1 is expected")
                print(list)
            case .failure(let error):
                XCTFail("Failed to fetch audio \(audio.sid) staff, reason: \(error)")
            }
        }
        let urls = expectation(description: "Single audio url fetch")
        audio.getURLs { result in
            defer { urls.fulfill() }
            switch result {
            case .success(let url):
                dump(url)
            case .failure(let error):
                XCTFail("\(audio.sid) staff fetch failed, reason: \(error)")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
        print()
    }

    func testCollaborativeAudioFetching() {
        for sid in [418827, 729124] {
            let audio = BKAudio(au: sid)
            let info = expectation(description: "Collaborative audio info fetch")
            audio.getInfo { result in
                defer { info.fulfill() }
                switch result {
                case .success(let audioInfo):
                    dump(audioInfo)
                    XCTAssertNotNil(audioInfo.lyrics)
                    print(audioInfo.lyrics!)
                case .failure(let error):
                    XCTFail("\(audio.sid) fetch failed, reason: \(error)")
                }
            }
            let staff = expectation(description: "Collaborative audio staff fetch")
            audio.getStaffList { result in
                defer { staff.fulfill() }
                switch result {
                case .success(let list):
                    XCTAssertNotEqual(list.count, 1, "Only 1 staff found were multiple is expected")
                    print(list)
                case .failure(let error):
                    XCTFail("\(audio.sid) staff fetch failed, reason: \(error)")
                }
            }
            let urls = expectation(description: "Collaborative audio url fetch")
            audio.getURLs { result in
                defer { urls.fulfill() }
                switch result {
                case .success(let url):
                    dump(url)
                case .failure(let error):
                    XCTFail("\(audio.sid) download failed, reason: \(error)")
                }
            }
            waitForExpectations(timeout: 60, handler: nil)
            print()
        }
    }

    func testUserInfoFetching() {
        [0, 639647, 110352985, 14767902, 2].forEach { mid in
            print("BEGIN \(mid)")
            let user = BKUpUser(id: mid)
            let basicInfo = expectation(description: "Basic Info of \(mid)")
            user.getBasicInfo { result in
                defer { basicInfo.fulfill() }
                switch result {
                case .success(let info):
                    dump(info)
                    print()
                case .failure(let error):
                    XCTAssertEqual(mid, 0, "Basic Info \(mid) fetch failed, reason: \(error)")
                }
            }
            let info = expectation(description: "Info of \(mid)")
            user.getInfo { result in
                defer { info.fulfill() }
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
            }
            let relation = expectation(description: "Relationship of \(mid)")
            user.getRelationship { result in
                defer { relation.fulfill() }
                switch result {
                case .success(let relationship):
                    dump(relationship)
                    print()
                case .failure(let error):
                    XCTAssertEqual(mid, 0, "User \(mid) relationship fetch failed, reason: \(error)")
                }
            }
            let audioStat = expectation(description: "Audio stat of \(mid)")
            user.getAudioStat { result in
                defer { audioStat.fulfill() }
                switch result {
                case .success(let audioStat):
                    dump(audioStat)
                case .failure(let error):
                    print(error)
                }
                print()
            }
            let upStat = expectation(description: "Up stat of \(mid)")
            user.getStat { result in
                defer { upStat.fulfill() }
                switch result {
                case .success(let stat):
                    dump(stat)
                    print()
                case .failure(let error):
                    XCTAssertEqual(mid, 0, "Up\(mid) stat fetch failed, reason: \(error)")
                }
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
        ("testHiddenVideoInfoFetching", testHiddenVideoInfoFetching),
        ("testVideoPageFetching", testVideoPageFetching),
        ("testAudioFail", testAudioFail),
        ("testAudioSingleFetching", testAudioSingleFetching),
        ("testCollaborativeAudioFetching", testCollaborativeAudioFetching),
        ("testUserInfoFetching", testUserInfoFetching)
    ]
}
#endif
