#if !os(watchOS)
import XCTest
@testable import BilibiliKitTests

XCTMain([
    testCase(BilibiliKitTests.allTests),
])
#endif
