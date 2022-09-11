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
    private var mockImageDownloader: MockImageDownloader!
    
    override func setUp() {
        super.setUp()
        
        mockService = MockGithubService()
        mockDelegate = MockUserListViewControllerViewModelDelegate()
        mockLocalStorage = MockLocalStorage()
        mockImageDownloader = MockImageDownloader()
        
        sut = UserListViewControllerViewModel(
            service: mockService,
            localStorage: mockLocalStorage,
            imageDowdloader: mockImageDownloader,
            delegate: mockDelegate
        )
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockDelegate = nil
        mockService = nil
        mockLocalStorage = nil
        mockImageDownloader = nil
        sut = nil
    }
    
    func test_initialValues() {
        XCTAssertEqual(sut.lastId, 0)
        XCTAssertTrue(sut.users.isEmpty)
        XCTAssertTrue(sut.userCells.isEmpty)
        XCTAssertTrue(sut.searchText.isEmpty)
    }
    
    func test_fetchUsers_successfully() {
        let timestamp = Date()
        let users = uniqueUsers()
        
        sut.fetchUsers(timestamp: timestamp)
        
        mockService.fetchUsersArgs.first?.1(.success(users))
        
        XCTAssertEqual(sut.lastId, 15520417)
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertIdentical(mockDelegate.fetchUsersSuccessfullyArgs.first, sut)
        
        let first = mockLocalStorage.insertArgs.first
        XCTAssertEqual(first?.0, users)
        XCTAssertEqual(first?.1, timestamp)
    }
    
    func test_fetchUsers_fail() {
        sut.fetchUsers(timestamp: Date())
        
        mockService.fetchUsersArgs.first?.1(.failure(anyError))
        
        XCTAssertEqual(sut.lastId, 0)
        
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
    }
    
    func test_retrieveCachedSuccessfully_thenFetchUsersSuccessfully() {
        let timestamp = Date()
        let retriveResult: RetrieveCachedResult = .found(users: uniqueUsers(), timestamp: timestamp)
        let users = uniqueUsers()
        
        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.success(users))
        
        XCTAssertEqual(sut.users.count, 4)
    }
    
    func test_retrieveCachedFail_thenFetchUsersFail() {
        let retriveResult: RetrieveCachedResult = .failure(anyError)
        
        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)
        
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.failure(anyError))
        
        XCTAssertEqual(sut.users.count, 0)
    }
    
    func test_retrieveCachedSuccessfully_thenFetchUsersFail() {
        let timestamp = Date()
        let retriveResult: RetrieveCachedResult = .found(users: uniqueUsers(), timestamp: timestamp)

        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)

        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.failure(anyError))

        XCTAssertEqual(sut.users.count, 2)
    }

    func test_retrieveCachedFail_thenFetchUsersSuccessfully() {
        let retriveResult: RetrieveCachedResult = .failure(anyError)
        let users = uniqueUsers()

        sut.retrieveCached()
        mockLocalStorage.retriveArgs.first?(retriveResult)

        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(users))

        XCTAssertEqual(sut.users.count, 2)
    }
    
    func test_userCells_updatedWhenGithubUsersAreChanged() {
        var users = [uniqueUser()]
        let timestamp = Date()
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.success(users))
        XCTAssertEqual(sut.users.count, sut.userCells.count)
        
        users[0].note = "note"
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.last?.1(.success(users))
        XCTAssertEqual(sut.users.count, sut.userCells.count)
        
        users[0].note = "note 2"
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.last?.1(.success(users))
        XCTAssertEqual(sut.users.count, sut.userCells.count)
        
        XCTAssertEqual(sut.userCells.count, 3)
    }
    
    func test_users_notNeedToUpdateIfNewUsersAreTheSame() {
        let users = [uniqueUser()]
        let timestamp = Date()
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.success(users))
        XCTAssertEqual(sut.users.count, 1)
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.last?.1(.success(users))
        
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.last?.1(.success(users))
        
        XCTAssertEqual(sut.userCells.count, 1) // Still 1
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
        XCTAssertEqual(sut.userCells[0][0], .normal(users[0]))
        XCTAssertEqual(sut.userCells[1][0], .note(users[1]))
        XCTAssertEqual(sut.userCells[2][0], .normal(users[2]))
        XCTAssertEqual(sut.userCells[3][0], .inverted(users[3]))
        XCTAssertEqual(sut.userCells[4][0], .normal(users[4]))
        XCTAssertEqual(sut.userCells[5][0], .normal(users[5]))
        XCTAssertEqual(sut.userCells[6][0], .normal(users[6]))
        XCTAssertEqual(sut.userCells[7][0], .invertedNote(users[7]))
    }
    
    func test_numberOfSections() {
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(uniqueUsers()))
        
        XCTAssertEqual(sut.numberOfSections(), 2)
        XCTAssertEqual(sut.numberOfSections(), sut.userCells.count)
    }
    
    func test_numberOfRowsInSection() {
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(uniqueUsers()))
        
        XCTAssertEqual(sut.numberOfRowsInSection(section: 0), 1)
        XCTAssertEqual(sut.numberOfRowsInSection(section: 1), 1)
    }
    
    func test_userCell() {
        var users: [GithubUser] = []
        for i in 0..<8 {
            users.append(uniqueUser())
            
            if i == 1 || i == 7 {
                users[i].note = "some note"
            }
        }
        
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(users))
        
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 0)), .normal(users[0]))
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 1)), .note(users[1]))
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 2)), .normal(users[2]))
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 3)), .inverted(users[3]))
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 4)), .normal(users[4]))
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 5)), .normal(users[5]))
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 6)), .normal(users[6]))
        XCTAssertEqual(sut.userCell(for: IndexPath(row: 0, section: 7)), .invertedNote(users[7]))
    }
    
    func test_heightForRowAtIndexPath() {
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(uniqueUsers()))
        
        XCTAssertEqual(sut.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), 76)
        XCTAssertEqual(sut.heightForRowAt(indexPath: IndexPath(row: 0, section: 1)), 76)
    }
    
    func test_heightForFooter() {
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(uniqueUsers()))
        
        var section = 0
        XCTAssertEqual(sut.heightForFooter(in: section), 8)
        section = 1
        XCTAssertEqual(sut.heightForFooter(in: section), 8)
    }
    
    func test_fetchAvatar() {
        let urlString = "https://avatars.githubusercontent.com/u/15520417?v=4"
        let data = urlString.data(using: .utf8)
        let exp = expectation(description: "Wait for completion")
        
        var receivedData: Data?
        sut.fetchAvatar(from: urlString) { data in
            receivedData = data
            exp.fulfill()
        }
        mockImageDownloader.fetchImageArgs.first?.1(data)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(mockImageDownloader.fetchImageArgs.first?.0, urlString)
        XCTAssertEqual(receivedData, data)
    }
    
    func test_allowLoadMore() {
        sut.searchText = ""
        XCTAssertTrue(sut.allowLoadMore)
        
        sut.searchText = "tawk"
        XCTAssertFalse(sut.allowLoadMore)
    }
    
    func test_filteredUserCells_whileNotSearch() {
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(uniqueUsers()))
        
        sut.searchText = ""
        
        XCTAssertEqual(sut.filteredUserCells.count, 2)
    }
    
    func test_filteredUserCells_whileSearching() {
        var users = uniqueUsers()
        users.append(
            GithubUser(
                login: "newuser",
                id: 15520417,
                avatarUrl: "https://avatars.githubusercontent.com/u/15520417?v=4",
                url: "https://api.github.com/users/itopstack",
                followersUrl: "https://api.github.com/users/itopstack/followers",
                organizationsUrl: "https://api.github.com/users/itopstack/orgs",
                reposUrl: "https://api.github.com/users/itopstack/repos",
                type: "User",
                siteAdmin: false
            )
        ) // total users is 3
        sut.fetchUsers(timestamp: Date())
        mockService.fetchUsersArgs.first?.1(.success(users))
        
        sut.searchText = "new"
        
        XCTAssertEqual(sut.filteredUserCells.count, 1)
    }
    
    func test_updateNote() {
        let note = "my note"
        let timestamp = Date()
        sut.fetchUsers(timestamp: timestamp)
        mockService.fetchUsersArgs.first?.1(.success(uniqueUsers()))
        
        XCTAssertEqual(sut.users.first?.note.isEmpty, true)
        
        sut.updateNote(note, at: 0, timestamp: timestamp)
        
        XCTAssertEqual(sut.users.first?.note, note)
        
        let last = mockLocalStorage.insertArgs.last
        XCTAssertEqual(last?.0.first?.note, note)
        XCTAssertEqual(last?.1, timestamp)
    }
}

// MARK: - Mocks

private final class MockGithubService: UsersFetchable {
    private(set) var fetchUsersArgs: [(Int, (Result<[GithubUser], Error>) -> Void)] = []
    func fetchUsers(since: Int, completion: @escaping (Result<[GithubUser], Error>) -> Void) {
        fetchUsersArgs.append((since, completion))
    }
}

private final class MockUserListViewControllerViewModelDelegate: UserListViewControllerViewModelDelegate {
    
    private(set) var fetchUsersSuccessfullyArgs: [UserListViewControllerViewModel] = []
    func userListViewControllerViewModelDidUpdateUsersSuccessfully(_ viewModel: UserListViewControllerViewModel) {
        fetchUsersSuccessfullyArgs.append(viewModel)
    }
    
    private(set) var fetchUsersFailArgs: [(UserListViewControllerViewModel, String)] = []
    func userListViewControllerViewModelDidFetchUsersFail(_ viewModel: UserListViewControllerViewModel, errorMessage: String) {
        fetchUsersFailArgs.append((viewModel, errorMessage))
    }
}

private final class MockLocalStorage: LocalStorage {
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

final class MockImageDownloader: ImageDownloadable {
    private(set) var fetchImageArgs: [(String, (Data?) -> Void)] = []
    func fetch(from urlString: String, completion: @escaping (Data?) -> Void) {
        fetchImageArgs.append((urlString, completion))
    }
}
