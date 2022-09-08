//
//  GithubUserTests.swift
//  TawkTestTests
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import XCTest
@testable import TawkTest

class GithubUserTests: XCTestCase {
    func test_decode_json() throws {
        let data = try XCTUnwrap(mockJsonString.data(using: .utf8))
        
        // sut stand for `System Under Test`
        let sut = try JSONDecoder().decode(GithubUser.self, from: data)
        
        XCTAssertEqual(sut.url, "https://api.github.com/users/itopstack")
        XCTAssertEqual(sut.type, "User")
        XCTAssertEqual(sut.avatarUrl, "https://avatars.githubusercontent.com/u/15520417?v=4")
        XCTAssertEqual(sut.followersUrl, "https://api.github.com/users/itopstack/followers")
        XCTAssertEqual(sut.id, 15520417)
        XCTAssertEqual(sut.organizationsUrl, "https://api.github.com/users/itopstack/orgs")
        XCTAssertEqual(sut.reposUrl, "https://api.github.com/users/itopstack/repos")
        XCTAssertFalse(sut.siteAdmin)
        XCTAssertEqual(sut.login, "itopstack")
        XCTAssertFalse(sut.hasSeen)
        XCTAssertNil(sut.note)
    }
}

extension GithubUserTests {
    private var mockJsonString: String {
        """
        {
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
        }
        """
    }
}
