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
        XCTAssertFalse(sut.isDataFromCached)
        XCTAssertTrue(sut.userCells.isEmpty)
    }
    
    func test_fetchUsers_successfully() {
        let timestamp = Date()
        let users = uniqueUsers()
        
        sut.fetchUsers(timestamp: timestamp)
        
        mockService.fetchUsersArgs.first?.1(.success(users))
        
        XCTAssertEqual(sut.userId, 1)
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertIdentical(mockDelegate.fetchUsersSuccessfullyArgs.first, sut)
        
        let first = mockLocalStorage.insertArgs.first
        XCTAssertEqual(first?.0, users)
        XCTAssertEqual(first?.1, timestamp)
    }
    
    func test_fetchUsers_fail() {
        sut.fetchUsers(timestamp: Date())
        
        mockService.fetchUsersArgs.first?.1(.failure(anyError))
        
        XCTAssertEqual(sut.userId, 0)
        XCTAssertNotNil(sut.error)
        
        let first = mockDelegate.fetchUsersFailArgs.first
        XCTAssertIdentical(first?.0, sut)
        XCTAssertEqual(first?.1, anyError.localizedDescription)
    }
    
    func test_retrieveCached_successfully() {
        let retriveResult: RetrieveCachedResult = .found(users: uniqueUsers(), timestamp: Date())
        
        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)
        
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertIdentical(mockDelegate.fetchUsersSuccessfullyArgs.first, sut)
        XCTAssertTrue(sut.isDataFromCached)
    }
    
    func test_retrieveCachedSuccessfully_thenFetchUsersSuccessfully() {
        let timestamp = Date()
        let retriveResult: RetrieveCachedResult = .found(users: uniqueUsers(), timestamp: timestamp)
        let users = uniqueUsers()
        
        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.success(users))
        
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertFalse(sut.isDataFromCached)
    }
    
    func test_retrieveCachedFail_thenFetchUsersFail() {
        let retriveResult: RetrieveCachedResult = .failure(anyError)
        
        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)
        
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.failure(anyError))
        
        XCTAssertEqual(sut.users.count, 0)
        XCTAssertFalse(sut.isDataFromCached)
    }
    
    func test_retrieveCachedSuccessfully_thenFetchUsersFail() {
        let timestamp = Date()
        let retriveResult: RetrieveCachedResult = .found(users: uniqueUsers(), timestamp: timestamp)

        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)

        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.failure(anyError))

        XCTAssertEqual(sut.users.count, 2)
        XCTAssertTrue(sut.isDataFromCached)
    }

    func test_retrieveCachedFail_thenFetchUsersSuccessfully() {
        let retriveResult: RetrieveCachedResult = .failure(anyError)
        let users = uniqueUsers()

        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)

        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(users))

        XCTAssertEqual(sut.users.count, 2)
        XCTAssertFalse(sut.isDataFromCached)
    }
    
    func test_userCells_updatedWhenGithubUsersAreChanged() {
        let users = [uniqueUser()]
        let timestamp = Date()
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.success(users))
        XCTAssertEqual(sut.users.count, sut.userCells.count)
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.last?.1(.success(users))
        XCTAssertEqual(sut.users.count, sut.userCells.count)
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.last?.1(.success(users))
        XCTAssertEqual(sut.users.count, sut.userCells.count)
        
        XCTAssertEqual(sut.userCells.count, 3)
    }
    
    func test_userCells_typeAreCorrectBasedGithubUsers() {
        var users: [GithubUser] = []
        for i in 0..<8 {
            users.append(uniqueUser())
            
            if i == 1 || i == 7 {
                users[i].note = "some note"
            }
        }
        
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(users))
        
        XCTAssertEqual(sut.userCells.count, 8)
        XCTAssertTrue(sut.userCells[0][0] is NormalCell)
        XCTAssertTrue(sut.userCells[1][0] is NoteCell)
        XCTAssertTrue(sut.userCells[2][0] is NormalCell)
        XCTAssertTrue(sut.userCells[3][0] is InvertedCell)
        XCTAssertTrue(sut.userCells[4][0] is NormalCell)
        XCTAssertTrue(sut.userCells[5][0] is NormalCell)
        XCTAssertTrue(sut.userCells[6][0] is NormalCell)
        XCTAssertTrue(sut.userCells[7][0] is InvertedNoteCell)
        
        sut.userCells.forEach { cell in
            XCTAssertNotNil(cell[0].user)
        }
    }
}

// MARK: - Mocks

final class MockGithubService: UsersFetchable {
    private(set) var fetchUsersArgs: [(Int, (Result<[GithubUser], Error>) -> Void)] = []
    func fetchUsers(since: Int, completion: @escaping (Result<[GithubUser], Error>) -> Void) {
        fetchUsersArgs.append((since, completion))
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
