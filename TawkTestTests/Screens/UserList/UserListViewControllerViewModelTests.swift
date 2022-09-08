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
    private var mockLocalStorage: MockLocalStorage!
    
    override func setUp() {
        super.setUp()
        
        mockService = MockGithubService()
        mockDelegate = MockUserListViewControllerViewModelDelegate()
        mockLocalStorage = MockLocalStorage()
        sut = UserListViewControllerViewModel(service: mockService, localStorage: mockLocalStorage, delegate: mockDelegate)
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
        let timestamp = Date()
        mockService.testCase = .success
        
        sut.fetchUsers(timestamp: timestamp)
        
        XCTAssertEqual(sut.userId, 1)
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertIdentical(mockDelegate.fetchUsersSuccessfullyArgs.first, sut)
        
        let first = mockLocalStorage.insertArgs.first
        XCTAssertEqual(first?.0, uniqueUsers())
        XCTAssertEqual(first?.1, timestamp)
    }
    
    func test_fetchUsers_fail() {
        mockService.testCase = .failure
        
        sut.fetchUsers(timestamp: Date())
        
        XCTAssertEqual(sut.userId, 0)
        XCTAssertNotNil(sut.error)
        
        let first = mockDelegate.fetchUsersFailArgs.first
        XCTAssertIdentical(first?.0, sut)
        XCTAssertEqual(first?.1, anyError.localizedDescription)
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
            completion(.success(uniqueUsers()))
        case .failure:
            completion(.failure(anyError))
        default:
            fatalError("Test case is missing")
        }
    }
}

final class MockUserListViewControllerViewModelDelegate: UserListViewControllerViewModelDelegate {
    
    private(set) var fetchUsersSuccessfullyArgs: [UserListViewControllerViewModel] = []
    func userListViewControllerViewModelDidFetchUsersSuccessfully(_ viewModel: UserListViewControllerViewModel) {
        fetchUsersSuccessfullyArgs.append(viewModel)
    }
    
    private(set) var fetchUsersFailArgs: [(UserListViewControllerViewModel, String)] = []
    func userListViewControllerViewModelDidFetchUsersFail(_ viewModel: UserListViewControllerViewModel, errorMessage: String) {
        fetchUsersFailArgs.append((viewModel, errorMessage))
    }
}

final class MockLocalStorage: LocalStorage {
    private(set) var retriveArgs: [RetrievalCompletion] = []
    func retrieve(completion: @escaping RetrievalCompletion) {
        retriveArgs.append(completion)
    }
    
    private(set) var insertArgs: [([GithubUser], Date, InsertionCompletion)] = []
    func insert(_ users: [GithubUser], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertArgs.append((users, timestamp, completion))
    }
    
    private(set) var deleteCachedUsersArgs: [DeletionCompletion] = []
    func deleteCachedUsers(completion: @escaping DeletionCompletion) {
        deleteCachedUsersArgs.append(completion)
    }
}
