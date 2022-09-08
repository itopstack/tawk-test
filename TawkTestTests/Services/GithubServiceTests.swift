//
//  GithubServiceTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import XCTest
@testable import TawkTest

class GithubServiceTests: XCTestCase {
    private var sut: GithubService!
    private var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        
        mockSession = MockURLSession()
        sut = GithubService(session: mockSession)
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockSession = nil
        sut = nil
    }
    
    func test_fetchUsers_error() {
        mockSession.testCase = .error
        
        expect(sut) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as NSError, anyError)
            default:
                XCTFail("Expect failure case but got something else")
            }
        }
    }
    
    func test_fetchUsers_invalidStatusCode() {
        mockSession.testCase = .invalidStatusCode
        
        expect(sut) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? MyError, .invalidStatusCode)
            default:
                XCTFail("Expect failure case but got something else")
            }
        }
    }
    
    func test_fetchUsers_missingData() {
        mockSession.testCase = .missingData
        
        expect(sut) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? MyError, .missingData)
            default:
                XCTFail("Expect failure case but got something else")
            }
        }
    }
    
    func test_fetchUsers_success() {
        mockSession.testCase = .success
        
        expect(sut) { result in
            switch result {
            case let .success(users):
                XCTAssertEqual(users.count, 1)
            default:
                XCTFail("Expect success case but got something else")
            }
        }
    }
    
    // MARK: - Helpers
    
    func expect(_ sut: GithubService, action: @escaping (Result<[GithubUser], Error>) -> Void)  {
        let exp = expectation(description: "Wait for completion")
        sut.fetchUsers(since: 0) { result in
            action(result)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Mocks

private final class MockURLSession: Requestable {
    enum TestCase {
        case error
        case success
        case invalidStatusCode
        case missingData
    }
    
    var testCase: TestCase?
    
    func request(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        switch testCase {
        case .error:
            completion(nil, nil, anyError)
            
        case .success:
            let response = HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)
            let data = jsonResponse.data(using: .utf8)
            completion(data, response, nil)
            
        case .missingData:
            let response = HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)
            completion(nil, response, nil)
            
        case .invalidStatusCode:
            let response = HTTPURLResponse(url: anyURL, statusCode: 400, httpVersion: nil, headerFields: nil)
            completion(nil, response, nil)
            
        case .none:
            fatalError("Missing test case")
        }
    }
    
    private let jsonResponse = """
        [{
        "login": "itopstack",
        "id": 15520417,
        "node_id": "MDQ6VXNlcjE1NTIwNDE3",
        "avatar_url": "https://avatars.githubusercontent.com/u/15520417?v=4",
        "gravatar_id": "",
        "url": "https://api.github.com/users/itopstack",
        "html_url": "https://github.com/itopstack",
        "followers_url": "https://api.github.com/users/itopstack/followers",
        "following_url": "https://api.github.com/users/itopstack/following{/other_user}",
        "gists_url": "https://api.github.com/users/itopstack/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/itopstack/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/itopstack/subscriptions",
        "organizations_url": "https://api.github.com/users/itopstack/orgs",
        "repos_url": "https://api.github.com/users/itopstack/repos",
        "events_url": "https://api.github.com/users/itopstack/events{/privacy}",
        "received_events_url": "https://api.github.com/users/itopstack/received_events",
        "type": "User",
        "site_admin": false
        }]
        """
}
