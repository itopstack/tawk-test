//
//  UserCellTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 10/9/2565 BE.
//

import XCTest
@testable import TawkTest

class UserCellTests: XCTestCase {
    func test_allCases() {
        XCTAssertEqual(UserCell.allCases, [
            .normal(.default),
            .note(.default),
            .inverted(.default),
            .invertedNote(.default)
        ])
    }
    
    func test_cellClass() {
        XCTAssertTrue(UserCell.normal(.default).cellClass is NormalCell.Type)
        XCTAssertTrue(UserCell.note(.default).cellClass is NoteCell.Type)
        XCTAssertTrue(UserCell.inverted(.default).cellClass is InvertedCell.Type)
        XCTAssertTrue(UserCell.invertedNote(.default).cellClass is InvertedNoteCell.Type)
    }
    
    func test_cellIdentifier() {
        XCTAssertEqual(UserCell.normal(.default).cellIdentifier, "TawkTest.NormalCell")
        XCTAssertEqual(UserCell.note(.default).cellIdentifier, "TawkTest.NoteCell")
        XCTAssertEqual(UserCell.inverted(.default).cellIdentifier, "TawkTest.InvertedCell")
        XCTAssertEqual(UserCell.invertedNote(.default).cellIdentifier, "TawkTest.InvertedNoteCell")
    }
}
