//
//  UserListViewControllerViewModelTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import XCTest
@testable import TawkTest

class UserListViewControllerViewModelTests: XCTestCase {
    private var sut: UserListViewControllerViewModel!
    private var mockService: MockGithubService!
    
    override func setUp() {
        super.setUp()
        
        mockService = MockGithubService()
        sut = UserListViewControllerViewModel(service: mockService)
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockService = nil
        sut = nil
    }
    
    func test_initialValues() {
        XCTAssertEqual(sut.userId, 0)
    }
    
    func test_userId_increaseIfFetchSuccessfully() {
        mockService.testCase = .success
        
        sut.fetchUsers()
        
        XCTAssertEqual(sut.userId, 1)
    }
    
    func test_userId_sameIfFetchFail() {
        mockService.testCase = .failure
        
        sut.fetchUsers()
        
        XCTAssertEqual(sut.userId, 0)
    }
}

// MARK: - Mocks

final class MockGithubService: UsersFetchable {
    enum TestCase {
        case success
        case failure
    }
    
    var testCase: TestCase?
    
    func fetchUsers(since: Int, completion: @escaping (Result<[GithubUser], Error>) -> Void) {
        switch testCase {
        case .success:
            completion(.success([]))
        case .failure:
            completion(.failure(anyError))
        default:
            fatalError("Test case is missing")
        }
    }
}
