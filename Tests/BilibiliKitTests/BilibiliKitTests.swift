//
//  BilibiliKitTests.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 12/13/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

#if !os(watchOS)
import XCTest
@testable import BilibiliKit

class BilibiliKitTests: XCTestCase {
    func testVideoInfoFetching() {
        let goal = expectation(description: "Video info fetch")
        BKVideo.av(170001).getInfo { result in
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

    func testAVBVInfoConsistency() {
        let goal = expectation(description: "AV+BV video info fetch")
        BKVideo.av(4305072).getInfo { result in
            switch result {
            case .success(let info):
                print()
                dump(info)
                print()
                BKVideo.bv("BV18s411z7ST").getInfo { result in
                    defer { goal.fulfill() }
                    switch result {
                    case .success(let bvInfo):
                        print()
                        dump(bvInfo)
                        let encoder = JSONEncoder()
                        XCTAssertEqual(
                            try! encoder.encode(info),
                            try! encoder.encode(bvInfo)
                        )
                        print()
                    case .failure(let error):
                        XCTFail("No info for 4305072, reason: \(error)")
                    }
                }
            case .failure(let error):
                XCTFail("No info for 4305072, reason: \(error)")
                goal.fulfill()
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testHiddenVideoInfoFetching() {
        let goal = expectation(description: "Hidden video info fetch")
        func fetchHiddenVideo() {
            BKVideo.av(5510557).getInfo { result in
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
            if let username = ENV["BILI_USER"],
                let password = ENV["BILI_PASS"] {
                BKSession.shared.login(username, password: password) {
                    if ENV["BILI_COOKIE_SECURE"] == "\(username)-\(password)" {
                        dump($0)
                    }
                    fetchHiddenVideo()
                }
            } else {
                print("No user configured, skipping...")
                goal.fulfill()
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testBangumiVideoFetching() {
        return
        let goal = expectation(description: "Bangumi video info fetch")
        BKVideo.bv("BV1rf4y1R7uF").getInfo { (result) in
            defer { goal.fulfill() }
            switch result {
            case .success(let info):
                print()
                dump(info)
                print()
            case .failure(let error):
                XCTFail("No info for bangumi, reason: \(error)")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testVideoPageFetching() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let goal = expectation(description: "Video page information fetch")
        BKVideo.av(8993458).p1 { result in
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
            guard case .failure(.responseError(reason: .emptyValue)) = result else {
                dump(result)
                return XCTFail("Valid info for invalid audio 0")
            }
        }
        let staff = expectation(description: "Nonexisting audio staff fetch")
        audio.getStaffList { result in
            defer { staff.fulfill() }
            switch result {
            case .failure(let error):
                guard case .failure(.responseError(reason: .emptyValue)) = result else {
                    dump(error)
                    return XCTFail("Wrong error produced")
                }
            case .success(let list):
                XCTFail("Found \(list) while no staff is expected")
            }
        }
        let urls = expectation(description: "Nonexisting audio url fetch")
        audio.getURLs { result in
            defer { urls.fulfill() }
            guard case .failure(.responseError(reason: .emptyValue)) = result else {
                dump(result)
                return XCTFail("Valid url for invalid audio 0")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
        print()
    }

    func testPaidAudio() {
        #warning("TODO")
    }

    func testRemovedAudioEmpty() {
        let audio = BKAudio(au: 360363)
        let info = expectation(description: "Removed audio info fetch")
        audio.getInfo { result in
            defer { info.fulfill() }
            guard case .failure(.responseError(reason: .emptyValue)) = result else {
                dump(result)
                return XCTFail("Did bilibili restore this audio?")
            }
        }
        let staff = expectation(description: "Removed audio staff fetch")
        audio.getStaffList { result in
            defer { staff.fulfill() }
            switch result {
            case .failure(let error):
                guard case .failure(.responseError(reason: .emptyValue)) = result else {
                    dump(error)
                    return XCTFail("Wrong error produced")
                }
            case .success(let list):
                XCTFail("Found \(list) while no staff is expected")
            }
        }
        let urls = expectation(description: "Removed audio url fetch")
        audio.getURLs { result in
            defer { urls.fulfill() }
            switch result {
            case .failure(let error):
                guard case .failure(.responseError(reason: .emptyValue)) = result else {
                    dump(error)
                    return XCTFail("Wrong error produced")
                }
            case .success(let urls):
                XCTFail("Found \(urls) while no url is expected")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
        print()
    }

    func testSoloAudioFetching() {
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
        for sid in [418827, 729124, 736986] {
            let audio = BKAudio(au: sid)
            let info = expectation(description: "Collaborative audio info fetch")
            audio.getInfo { result in
                defer { info.fulfill() }
                switch result {
                case .success(let audioInfo):
                    dump(audioInfo)
                    if sid != 736986 {
                        XCTAssertNotNil(audioInfo.lyrics)
                        print(audioInfo.lyrics!)
                    }
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
                    if mid == 0 { return } // expected to fail
                    if !BKSession.shared.isLoggedIn {
                        if case .responseError(reason: .emptyValue) = error {
                            return // failed correctly
                        }
                        dump(error)
                        return XCTFail("Up\(mid) stat fetch failed wrongly")
                    }
                    XCTFail("Up\(mid) stat fetch failed, reason: \(error)")
                }
            }
            waitForExpectations(timeout: 300, handler: nil)
            print("--END \(mid)")
            print()
            print()
        }
    }

    func testAVBVConvert() {
        XCTAssertEqual(BKVideo.av(170001), BKVideo.av(170001))
        XCTAssertEqual(BKVideo.bv("BV17x411w7KC"), BKVideo.av(170001))
        XCTAssertEqual(BKVideo.bv("BV1Q541167Qg"), BKVideo.av(455017605))
        XCTAssertEqual(BKVideo.bv("BV1mK4y1C7Bz"), BKVideo.av(882584971))
        XCTAssertEqual(BKVideo.av(465235), BKVideo.bv("BV1Kx411c7f5"))
        XCTAssertEqual(BKVideo.av(10000000), BKVideo.bv("BV1Ex411U7PA"))
        XCTAssertEqual(BKVideo.av(82054919), BKVideo.bv("BV1XJ41157tQ"))
        XCTAssertEqual(BKVideo.av(87854625), BKVideo.bv("BV1574114794"))
    }

    func testLiveRoomFetching() {
        let goal = expectation(description: "Live room info fetch")
        BKLiveRoom(421622).getInfo { (result) in
            defer { goal.fulfill() }
            switch result {
            case .success(let info):
                print()
                dump(info)
                print()
            case .failure(let error):
                dump(error)
                XCTFail("No live room info")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testNonExistentLiveRoomFetching() {
        let goal = expectation(description: "Empty live room fail as expected")
        BKLiveRoom(-1).getInfo { (result) in
            defer { goal.fulfill() }
            switch result {
            case .success(let info):
                print()
                dump(info)
                print()
                XCTFail("Found info above while expeting .emptyField")
            case .failure(let error):
                print()
                switch error {
                case .responseError(reason: .emptyValue):
                    break
                default:
                    dump(error)
                    XCTFail("Found above error while expecting .emptyField")
                }
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    func testArticleInfoFetching() {
        let goal = expectation(description: "Article info fetch")
        BKArticle(cv: 5167957).getInfo { result in
            defer { goal.fulfill() }
            switch result {
            case .success(let info):
                print()
                dump(info)
                print()
            case .failure(let error):
                dump(error)
                XCTFail("No article info")
            }
        }
        waitForExpectations(timeout: 60, handler: nil)
    }

    static var allTests = [
        ("testVideoInfoFetching", testVideoInfoFetching),
        ("testHiddenVideoInfoFetching", testHiddenVideoInfoFetching),
        ("testVideoPageFetching", testVideoPageFetching),
        ("testAudioFail", testAudioFail),
        ("testPaidAudio", testPaidAudio),
        ("testRemovedAudioEmpty", testRemovedAudioEmpty),
        ("testSoloAudioFetching", testSoloAudioFetching),
        ("testCollaborativeAudioFetching", testCollaborativeAudioFetching),
        ("testUserInfoFetching", testUserInfoFetching),
        ("testAVBVConvert", testAVBVConvert),
        ("testLiveRoomFetching", testLiveRoomFetching),
        ("testArticleInfoFetching", testArticleInfoFetching),
    ]
}
#endif
