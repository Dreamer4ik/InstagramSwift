//
//  InstagramSwiftTests.swift
//  InstagramSwiftTests
//
//  Created by Ivan Potapenko on 13.06.2022.
//

import XCTest

class InstagramSwiftTests: XCTestCase {

    func testNotificationIDCreation() {
        let first = "123_abc22"
        let second = "342_dwer"
        XCTAssertNotEqual(first, second)
    }
    
//    func testNotificationIDCreationFailure() {
//        let first = "123_abc22"
//        let second = "342_dwer"
//        XCTAssertEqual(first, second)
//    }

}
