//
//  HikeStrideTests.swift
//  HikeStrideTests
//
//  Created by Janindu Dissanayake on 2024-06-07.
//

import XCTest
@testable import HikeStride

final class HikeStrideTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFormatTime() {
        XCTAssertEqual(formatTime(3661), "01:01:01")
        XCTAssertEqual(formatTime(0), "00:00:00")
        XCTAssertEqual(formatTime(59), "00:00:59")
        XCTAssertEqual(formatTime(3600), "01:00:00")
        XCTAssertEqual(formatTime(86399), "23:59:59")
    }
    
    func testConvertDateString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date1 = dateFormatter.date(from: "2024-06-10 17:26:59")!
        XCTAssertEqual(convertDateString(date1), "17:26 Jun 10")
        
        let date2 = dateFormatter.date(from: "2024-01-01 00:00:00")!
        XCTAssertEqual(convertDateString(date2), "00:00 Jan 01")
        
        let date3 = dateFormatter.date(from: "2024-12-31 23:59:59")!
        XCTAssertEqual(convertDateString(date3), "23:59 Dec 31")
    }
    
    func testFormatTimeString() {
        XCTAssertEqual(formatTimeString("01:01:01"), "1h 01m 01s")
        XCTAssertEqual(formatTimeString("00:00:59"), "00m 59s")
        XCTAssertEqual(formatTimeString("00:59:59"), "59m 59s")
        XCTAssertEqual(formatTimeString("00:00:00"), "00m 00s")
        XCTAssertEqual(formatTimeString("23:59:59"), "23h 59m 59s")
        XCTAssertEqual(formatTimeString("invalid"), "Invalid time format")
    }
    
}
