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
    private var mockDelegate: MockUserListViewControllerViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        
        mockService = MockGithubService()
        mockDelegate = MockUserListViewControllerViewModelDelegate()
        sut = UserListViewControllerViewModel(service: mockService, delegate: mockDelegate)
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockDelegate = nil
        mockService = nil
        sut = nil
    }
    
    func test_initialValues() {
        XCTAssertEqual(sut.userId, 0)
        XCTAssertNil(sut.error)
        XCTAssertTrue(sut.users.isEmpty)
    }
    
    func test_fetchUsers_successfully() {
        mockService.testCase = .success
        
        sut.fetchUsers()
        
        XCTAssertEqual(sut.userId, 1)
        XCTAssertEqual(sut.users.count, 1)
        XCTAssertIdentical(mockDelegate.args1.first, sut)
    }
    
    func test_fetchUsers_fail() {
        mockService.testCase = .failure
        
        sut.fetchUsers()
        
        XCTAssertEqual(sut.userId, 0)
        XCTAssertNotNil(sut.error)
        XCTAssertIdentical(mockDelegate.args2.first?.0, sut)
        XCTAssertEqual(mockDelegate.args2.first?.1, anyError.localizedDescription)
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
            completion(.success([uniqueUser()]))
        case .failure:
            completion(.failure(anyError))
        default:
            fatalError("Test case is missing")
        }
    }
}

final class MockUserListViewControllerViewModelDelegate: UserListViewControllerViewModelDelegate {
    
    private(set) var args1: [UserListViewControllerViewModel] = []
    func userListViewControllerViewModelDidFetchUsersSuccessfully(_ viewModel: UserListViewControllerViewModel) {
        args1.append(viewModel)
    }
    
    private(set) var args2: [(UserListViewControllerViewModel, String)] = []
    func userListViewControllerViewModelDidFetchUsersFail(_ viewModel: UserListViewControllerViewModel, errorMessage: String) {
        args2.append((viewModel, errorMessage))
    }
}
