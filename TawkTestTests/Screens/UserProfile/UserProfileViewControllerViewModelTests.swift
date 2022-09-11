//
//  UserProfileViewControllerViewModelTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 11/9/2565 BE.
//

import XCTest
@testable import TawkTest

class UserProfileViewControllerViewModelTests: XCTestCase {
    private var sut: UserProfileViewControllerViewModel!
    private var mockGithubService: MockGithubService!
    private var mockImageDownloader: MockImageDownloader!
    
    override func setUp() {
        super.setUp()
        
        mockImageDownloader = MockImageDownloader()
        mockGithubService = MockGithubService()
        
        var user = uniqueUser()
        user.note = "my note"
        sut = UserProfileViewControllerViewModel(user: user, githubService: mockGithubService, imageDownloader: mockImageDownloader)
        
        let exp = expectation(description: "Wait for completion")
        sut.fetchUserProfile { _ in
            exp.fulfill()
        }
        mockGithubService.fetchUserProfileArgs.first?.1(.success(fakeProfile))
        waitForExpectations(timeout: 1)
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockImageDownloader = nil
        mockGithubService = nil
        sut = nil
    }
    
    func test_loadProfileImage() {
        let data = "expected image".data(using: .utf8)
        let exp = expectation(description: "Wait for completion")
        
        var receivedData: Data?
        sut.loadProfileImage { data in
            receivedData = data
            exp.fulfill()
        }
        mockImageDownloader.fetchImageArgs.first?.1(data)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(receivedData, data)
    }
    
    func test_followers() {
        XCTAssertEqual(sut.followers, "followers: 27")
    }
    
    func test_following() {
        XCTAssertEqual(sut.following, "following: 3")
    }
    
    func test_name() {
        XCTAssertEqual(sut.name, "name: Kittisak Phetrungnapha")
    }
    
    func test_email() {
        XCTAssertEqual(sut.email, "email: cs.sealsoul@gmail.com")
    }
    
    func test_location() {
        XCTAssertEqual(sut.location, "location: Thailand")
    }
    
    func test_repos() {
        XCTAssertEqual(sut.repos, "public repository: 65")
    }
    
    func test_bio() {
        XCTAssertEqual(sut.bio, "bio: my bio")
    }
    
    func test_note() {
        XCTAssertEqual(sut.note, "my note")
    }
}

// MARK: - Mocks

private final class MockGithubService: ProfileFetchable {
    private(set) var fetchUserProfileArgs: [(String, (Result<UserProfile, Error>) -> Void)] = []
    func fetchUserProfile(from urlString: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        fetchUserProfileArgs.append((urlString, completion))
    }
}

private let fakeProfile = UserProfile(
    login: "itopstack",
    id: 15520417,
    avatarUrl: "https://avatars.githubusercontent.com/u/15520417?v=4",
    name: "Kittisak Phetrungnapha",
    location: "Thailand",
    email: "cs.sealsoul@gmail.com",
    bio: "my bio",
    publicRepos: 65,
    followers: 27,
    following: 3
)
