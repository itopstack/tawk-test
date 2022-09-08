//
//  MyErrorTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import XCTest
@testable import TawkTest

class MyErrorTests: XCTestCase {
    func test_error_messages() {
        XCTAssertEqual(MyError.invalidURL.localizedDescription, "Invalid URL")
        XCTAssertEqual(MyError.invalidStatusCode.localizedDescription, "Invalid status code")
        XCTAssertEqual(MyError.missingResult.localizedDescription, "Result is missing")
        XCTAssertEqual(MyError.missingData.localizedDescription, "Data is missing")
    }
}
